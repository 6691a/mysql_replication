output "vpc" {
    value = aws_vpc.vpc
}

output "subnets" {
  value = aws_subnet.subnet
}

output "security_group" {
    value = {
        mysql = aws_security_group.mysql
        ssh = aws_security_group.ssh
    }
}