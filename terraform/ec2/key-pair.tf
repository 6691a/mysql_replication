resource "tls_private_key" "mysql_pem" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "mysql_pair" {
  key_name   = "mysql" 
  public_key = tls_private_key.mysql_pem.public_key_openssh

  provisioner "local-exec" {
    command = "echo '${tls_private_key.mysql_pem.private_key_pem}' > ./mysql.pem"
  }
}