output "vpc" {
    value = aws_vpc.vpc
}

output "subnets" {
    value = {
        "public" = values(aws_subnet.public_subnet)
        "private" = values(aws_subnet.private_subnet)
    }

#   value = {
        # public = aws_subnet.public_subnet
        # private = aws_subnet.private_subnet
    # }
}

# output "security_group" {
#     value = {
#         mysql = aws_security_group.mysql
#         ssh = aws_security_group.ssh
#     }
# }