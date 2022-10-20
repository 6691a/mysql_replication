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


resource "aws_route_table" "mysql_public" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = aws_vpc.vpc.tags.Name
  }
  route {
    cidr_block = "10.0.1.0/24"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "route_table_association_1" {
  count = length(local.config.subnet_groups)
  
  route_table_id = aws_route_table.mysql_public.id
  subnet_id      =  aws_subnet.subnet["public"].id

}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id

    tags = {
        Name = "Internet Gateway"
    }
}

# resource "aws_route" "route" {
#   route_table_id = aws_route_table.mysql_public.id

#   destination_cidr_block = "0.0.0.0/0"
#   depends_on                = [aws_route_table.mysql_public]
#   vpc_peering_connection_id = "pcx-45ff3dc1"

# }


# resource "aws_route" "r" {
#   route_table_id            = "rtb-4fbb3ac4"
#   destination_cidr_block    = "10.0.1.0/22"
  
# }