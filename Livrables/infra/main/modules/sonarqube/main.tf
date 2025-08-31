resource "aws_instance" "ubuntu_server" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]

  user_data = file("${path.module}/install_sonarqube.sh")
  key_name  = aws_key_pair.generated_key.key_name
}
