output "instance" {
    value = {
        public_ip =  aws_instance.my_sql.public_ip
        public_dns = aws_instance.my_sql.public_dns
        private_ip = aws_instance.my_sql.private_ip
        private_dns = aws_instance.my_sql.private_dns
    }
}