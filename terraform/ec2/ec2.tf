data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

   owners = ["099720109477"] # Canonical
}

resource "aws_instance" "public_ec2" {
  count = 1
  ami = data.aws_ami.ubuntu.image_id
  instance_type = "t2.micro"
  subnet_id = local.subnets.public[0].id
  key_name = aws_key_pair.mysql_pair.key_name
  associate_public_ip_address =  false

  vpc_security_group_ids = [ 
    local.security_group["mysql"].id,
    local.security_group["ssh"].id,
  ]

  tags = {
    Name = "public_ec2_${count.index}"
  }
}

resource "aws_instance" "private_ec2" {
  count = 0
  ami = data.aws_ami.ubuntu.image_id
  instance_type = "t2.micro"
  subnet_id = local.subnets.private[0].id
  key_name = aws_key_pair.mysql_pair.key_name
  associate_public_ip_address =  false

  vpc_security_group_ids = [ 
    local.security_group["mysql"].id,
    local.security_group["ssh"].id,
  ]

  tags = {
    Name = "private_ec2_${count.index}"
  }
}

resource "aws_eip" "public_eip" {
  count = length(aws_instance.public_ec2)
  vpc = true

  tags = {
    Name    = "public_ec2_eip${count.index}"
  }
}

resource "aws_eip_association" "public_eip_group" {
  count = length(aws_instance.public_ec2)

  instance_id   = aws_instance.public_ec2[count.index].id
  allocation_id = aws_eip.public_eip[count.index].id
}

resource "local_file" "inventory" {
  filename = "../../ansible/inventory.inv"
  content = <<EOF
%{ if length(aws_instance.private_ec2) != 0 ? true : false }
[private_ec2:vars]
ansible_ssh_private_key_file=./${local.context.pem}.pem
ansible_user=ubuntu
ansible_ssh_common_args="-o ProxyCommand="ssh -o StrictHostKeyChecking=no -q ubuntu@${aws_eip.public_eip[0].public_ip} -o IdentityFile=./${local.context.pem}.pem -o port=22 -W %h:%p"" 

[private_ec2]
%{ for index, instance in aws_instance.private_ec2}private${index} ansible_host=${instance.private_ip}
%{ endfor }
%{ endif }

%{ if length(aws_eip.public_eip) != 0 ? true : false }
[public_ec2:vars]
ansible_ssh_private_key_file=./${local.context.pem}.pem
ansible_user=ubuntu

[public_ec2]
%{ for index, instance in aws_eip.public_eip}public${index} ansible_host=${instance.public_ip}
%{ endfor }
%{ endif }
  EOF
}