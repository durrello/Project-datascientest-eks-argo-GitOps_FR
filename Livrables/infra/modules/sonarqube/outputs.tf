# modules/sonarqube/outputs.tf
output "instance_id" {
  description = "ID of the SonarQube EC2 instance"
  value       = aws_instance.sonarqube.id
}

output "public_ip" {
  description = "Public IP address of SonarQube instance"
  value       = aws_eip.sonarqube.public_ip
}

output "private_ip" {
  description = "Private IP address of SonarQube instance"
  value       = aws_instance.sonarqube.private_ip
}

output "security_group_id" {
  description = "ID of the SonarQube security group"
  value       = aws_security_group.sonarqube.id
}

output "sonarqube_url" {
  description = "SonarQube access URL"
  value       = "http://${aws_eip.sonarqube.public_ip}:9000"
}