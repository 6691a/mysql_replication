output "instance" {
    value = [
        for instance in aws_instance.my_sql : {
            public_ip =  instance.public_ip
            public_dns = instance.public_dns
            private_ip = instance.private_ip
            private_dns =instance.private_dns
        }
    ]
}