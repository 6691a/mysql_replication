output "instance" {
    
    value = {
        public = [
            for index, instance in aws_instance.public_ec2 : {
                public_ip = aws_eip.public_eip[index].public_ip
                public_dns = aws_eip.public_eip[index].public_dns
                private_ip = instance.private_ip
                private_dns = instance.private_dns
            }
        ]
        private = [
            for index, instance in aws_instance.private_ec2 : {
                public_ip = instance.public_ip
                public_dns = instance.public_dns
                private_ip = instance.private_ip
                private_dns = instance.private_dns
            }
        ]
    }
    depends_on = [
        aws_eip_association.public_eip_group
    ]
}