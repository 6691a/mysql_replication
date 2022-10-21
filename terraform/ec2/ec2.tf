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

resource "aws_instance" "my_sql" {
  ami = data.aws_ami.ubuntu.image_id
  instance_type = "t2.micro"
  subnet_id = local.subnets["public"].id
  key_name = aws_key_pair.mysql_pair.key_name

  vpc_security_group_ids = [ 
    local.security["mysql"].id,
    local.security["ssh"].id,

  ]

  tags = {
    Name = "${local.vpc.tags.Name}_mysql"
  }
}