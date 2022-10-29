resource "aws_vpc" "vpc" {
  cidr_block       = local.vpc.cidr
  enable_dns_hostnames  = true
  tags = {
    Name = local.vpc.name
  } 
}

resource "aws_subnet" "private_subnet"{
  for_each = {for subnet in local.subnet_group.private.subnets:  "${subnet.cidr}" => subnet}
  
  vpc_id = aws_vpc.vpc.id

 
  cidr_block = each.value.cidr
  availability_zone_id = each.value.az_id

  tags = {
    Name = "${aws_vpc.vpc.tags.Name}-private"
  }
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_subnet" {
  for_each = {for subnet in local.subnet_group.public.subnets:  "${subnet.cidr}" => subnet}

  vpc_id = aws_vpc.vpc.id

 
  cidr_block = each.value.cidr
  availability_zone_id = each.value.az_id

  tags = {
    Name = "${aws_vpc.vpc.tags.Name}-public"
  }
  map_public_ip_on_launch = false
  
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id

    tags = {
        Name = "mysql_internet_gateway"
    }
}

# resource "aws_eip" "ngw_ip" {
#   count = length(aws_subnet.public_subnet)
#   vpc = true

#   tags = {
#     Name    = "mysql_eip"
#     Service = var.prefix
#   }
# }

# resource "aws_nat_gateway" "ngw" {
#   count = length(aws_eip.ngw_ip)

#   allocation_id = aws_eip.ngw_ip[count.index].id
#   subnet_id = aws_subnet.public_subnet[local.subnet_group.public.subnets[count.index].cidr].id

#   tags = {
#     Name = "MySQL_NAT Gateway"
#   }
# }

# # private route table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "private_route_table"
  }
}

resource "aws_route_table_association" "private_route_tables" {
  for_each = aws_subnet.private_subnet
  
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_route_table.id
}

# resource "aws_route" "private_route" {
#   route_table_id              = aws_route_table.private_route_table.id
#   destination_cidr_block      = "0.0.0.0/0"
#   nat_gateway_id              = aws_nat_gateway.ngw[0].id
# }

# # public route table
resource "aws_default_route_table" "public_route_table" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
      Name = "default_public_route_table"
    }
}

resource "aws_route_table_association" "public_route_tables" {
  for_each = aws_subnet.public_subnet
  
  subnet_id      =  each.value.id
  route_table_id = aws_default_route_table.public_route_table.id
}

# resource "aws_security_group" "ssh" {
#   name        = "${aws_vpc.vpc.tags.Name}-ssh"
#   description = "Security Group for SSH"
#   vpc_id      = aws_vpc.vpc.id

#   ingress {
#     description = "Allow SSH from anywhere."
#     from_port = 22
#     to_port = 22
#     protocol = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
  
# }

# # resource "aws_security_group" "mysql" {
# #   name        = "${aws_vpc.vpc.tags.Name}-mysql"
# #   description = "Security Group for MySQL"
# #   vpc_id      = aws_vpc.vpc.id

# #   ingress {
# #     description ="Allow MySQL from anywhere."   
# #     from_port        = 3306
# #     to_port          = 3306
# #     protocol = "tcp"
# #     cidr_blocks = ["0.0.0.0/0"]
# #   }

# #    egress {
# #     description = "Allow to communicate to the Internet."
# #     from_port = 0
# #     to_port = 0
# #     protocol = "-1"
# #     cidr_blocks = [ "0.0.0.0/0" ]
# #    }
# # }