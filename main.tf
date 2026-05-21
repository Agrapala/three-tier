provider "aws" {
  region = "ap-south-1"
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Jenkins server security group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "jenkins_server" {
  ami                    = "ami-0c54f8b78468b2ba2"  # Ubuntu 22.04 ap-south-1
  instance_type          = "t1.micro"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  root_block_device {
    volume_size = 30
  }
  user_data = file("install.sh")

  tags = {
    Name = "Jenkins-Server"
  }
}

variable "key_name" {
  description = "devops-key"
}

output "jenkins_public_ip" {
  value = aws_instance.jenkins_server.public_ip
}