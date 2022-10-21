resource "aws_vpc" "vpc" {
  cidr_block       = local.config.vpc.cidr

  tags = {
    Name = local.config.vpc.name
  }
}


resource "aws_subnet" "subnet"{
  for_each = local.config.subnet_groups

  vpc_id = aws_vpc.vpc.id


  cidr_block = each.value.cidr
  availability_zone_id = each.value.az_id

  tags = {
    Name = "${aws_vpc.vpc.tags.Name}-${each.key}"
  }

  map_public_ip_on_launch = try(each.value.map_public_ip_on_launch, false)

}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id

    tags = {
        Name = "Internet Gateway"
    }
}

resource "aws_default_route_table" "public_route_table" {
    default_route_table_id = aws_vpc.vpc.default_route_table_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
        Name = "public route table"
    }
}

resource "aws_route_table_association" "public_route_tables" {
  count = length(local.config.subnet_groups)
  
  subnet_id      =  aws_subnet.subnet["public"].id
  route_table_id = aws_default_route_table.public_route_table.id
}

resource "aws_security_group" "ssh" {
  name        = "${aws_vpc.vpc.tags.Name}-ssh"
  description = "Security Group for SSH"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow SSH from anywhere."
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}

resource "aws_security_group" "mysql" {
  name        = "${aws_vpc.vpc.tags.Name}-mysql"
  description = "Security Group for MySQL"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description ="Allow MySQL from anywhere."   
    from_port        = 3306
    to_port          = 3306
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   egress {
    description = "Allow to communicate to the Internet."
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
   }
}