resource "tls_private_key" "mysql_pem" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "mysql_pair" {
  key_name   = "mysql" 
  public_key = tls_private_key.mysql_pem.public_key_openssh

  # provisioner "local-exec" {
  #   command = "echo '${tls_private_key.mysql_pem.private_key_pem}' > ../../ansible/${local.context.pem}.pem"
  # }
}

resource "local_file" "mysql_pair" {
  filename = "../../ansible/${local.context.pem}.pem"
  content = tls_private_key.mysql_pem.private_key_pem
  depends_on = [
    aws_key_pair.mysql_pair
  ]
  file_permission="0400"

}