output "sonarqube_ui" {
  value = "${aws_instance.ubuntu_server.public_ip}:9000"
}

output "ssh_access" {
  value = "ssh -i ${aws_key_pair.generated_key.key_name}.pem ubuntu@${aws_instance.ubuntu_server.public_ip}"
}

output "ubuntu_server_ip" {
  value = aws_instance.ubuntu_server.public_ip
}