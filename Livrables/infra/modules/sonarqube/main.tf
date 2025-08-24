# modules/sonarqube/main.tf

# Get latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group for SonarQube
resource "aws_security_group" "sonarqube" {
  name_prefix = "sonarqube-sg"
  vpc_id      = var.vpc_id

  ingress {
    description = "SonarQube Web UI"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "sonarqube-sg"
  })
}

# IAM Role for SonarQube instance
resource "aws_iam_role" "sonarqube" {
  name = "sonarqube-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "sonarqube_ssm" {
  role       = aws_iam_role.sonarqube.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "sonarqube" {
  name = "sonarqube-instance-profile"
  role = aws_iam_role.sonarqube.name
}

# User data script for SonarQube installation
locals {
  user_data = base64encode(templatefile("${path.module}/sonarqube-install.sh", {
    db_password = random_password.sonarqube_db.result
  }))
}

resource "random_password" "sonarqube_db" {
  length  = 16
  special = true
}

# SonarQube EC2 Instance
resource "aws_instance" "sonarqube" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name              = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.sonarqube.id]
  subnet_id             = var.subnet_id
  iam_instance_profile  = aws_iam_instance_profile.sonarqube.name

  user_data = local.user_data

  root_block_device {
    volume_type = "gp3"
    volume_size = 50
    encrypted   = true
  }

  tags = merge(var.tags, {
    Name = "sonarqube-server"
  })
}

# Elastic IP for SonarQube
resource "aws_eip" "sonarqube" {
  instance = aws_instance.sonarqube.id
  domain   = "vpc"

  tags = merge(var.tags, {
    Name = "sonarqube-eip"
  })
}