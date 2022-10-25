resource "aws_vpc" "vpc" {
  cidr_block       = local.vpc.cidr

  tags = {
    Name = local.vpc.name
  }
}
# module "subnet_group" {
#   source  = "tedilabs/network/aws//modules/subnet-group"
#   version = "0.24.0"

#   for_each = local.all.subnet_group

#   name                    = "${aws_vpc.vpc.tags.Name}-${each.key}"
#   vpc_id                  = aws_vpc.vpc.id
#   map_public_ip_on_launch = try(each.value.map_public_ip_on_launch, false)

#   subnets = {
#     for idx, subnet in try(each.value.subnets, []) :
#     "${aws_vpc.vpc.tags.Name}-${each.key}-${format("%03d", idx + 1)}/${regex("az[0-9]", subnet.az_id)}" => {
#       cidr_block           = subnet.cidr
#       availability_zone_id = subnet.az_id
#     }
#   }

# }

resource "aws_subnet" "private_subnet"{
  for_each = {for subnet in local.subnet_group.private.subnets:  "private_${subnet.cidr}" => subnet}
  
  vpc_id = aws_vpc.vpc.id

 
  cidr_block = each.value.cidr
  availability_zone_id = each.value.az_id

  tags = {
    Name = "${aws_vpc.vpc.tags.Name}-private"
  }
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_subnet" {
  for_each = {for subnet in local.subnet_group.public.subnets:  "public_${subnet.cidr}" => subnet}

  vpc_id = aws_vpc.vpc.id

 
  cidr_block = each.key
  availability_zone_id = each.value

  tags = {
    Name = "${aws_vpc.vpc.tags.Name}-public"
  }
  map_public_ip_on_launch = false
  
}

# resource "aws_internet_gateway" "igw" {
#     vpc_id = aws_vpc.vpc.id

#     tags = {
#         Name = "Internet Gateway"
#     }
# }

# resource "aws_eip" "ngw_ip" {
#     vpc = true
# }

# resource "aws_nat_gateway" "ngw" {
  
# }

# resource "aws_default_route_table" "public_route_table" {
#     default_route_table_id = aws_vpc.vpc.default_route_table_id

#     route {
#         cidr_block = "0.0.0.0/0"
#         gateway_id = aws_internet_gateway.igw.id
#     }

#     tags = {
#         Name = "public route table"
#     }
# }

# resource "aws_route_table_association" "public_route_tables" {
#   count = length(local.config.subnet_groups)
  
#   subnet_id      =  aws_subnet.subnet["public"].id
#   route_table_id = aws_default_route_table.public_route_table.id
# }

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

# resource "aws_security_group" "mysql" {
#   name        = "${aws_vpc.vpc.tags.Name}-mysql"
#   description = "Security Group for MySQL"
#   vpc_id      = aws_vpc.vpc.id

#   ingress {
#     description ="Allow MySQL from anywhere."   
#     from_port        = 3306
#     to_port          = 3306
#     protocol = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#    egress {
#     description = "Allow to communicate to the Internet."
#     from_port = 0
#     to_port = 0
#     protocol = "-1"
#     cidr_blocks = [ "0.0.0.0/0" ]
#    }
# }