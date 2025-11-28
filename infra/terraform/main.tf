terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "sheviantos-terraform-stage6"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "todo_app" {
  name_prefix = "todo-app-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "todo-app-sg"
  }
}

resource "aws_instance" "todo_app" {
  ami           = "ami-0fc5d935ebf8bc3bc"
  instance_type = "t3.micro"

  key_name               = "todo-app-key"
  vpc_security_group_ids = [aws_security_group.todo_app.id]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y docker.io docker-compose
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ubuntu
              EOF

  tags = {
    Name = "todo-app-stage6"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "todo-app-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCbYvhKGyAn8tyRLLkZfWhYlHmR410bVLK/C1V8ecEuARxQwteOXQ95V7RRobu7dS1oL+GqxosacQXitG5jXICP0oEHz+MxUpzXzAjx+e9Bn455Kgf3z9rLV5NdGr60BHl9QZXyOeumf04gaaPuHORIdS6YJqt4d8G+9tmq5u4f14WHLM02rtv70kCnkS/8gViQIHVZbLYxjZJ43CAgitNQ5DWzFb8POOffxHyiF8khkoDreO7S6uL4DD05LeKSSzJdOjax0NJexx1thFjbFj+Ugz8ixn+x+MSlCdedSAUZ/M7GTZ4LsGCL2xETB4o2QDtRBWrVUOO6ivzd/8GLVmmg5ryCQQLAYeJRf+FWKSigxcEJCPnbeEeEGyEqHbQNb7Cn/bxFlpAzNjo07ZR2UEvjwAk1dX8K+BczgKkN1B4xI3tN5mdX/sz9Oa7vgjHWnqFUgg+nEtX4A1YZzgtD9Oy7d9uEa8fkypjUFXj3JgLp8d0rpfgYd6G2L6cVTo33t37IdZCPF5wRN8dOBYXGPPY3XYYmOD9Nh1clvW4HROziX7ZljVrAgBkjw20CpX9h7IERGMK4LIQvHgHK7D5ZT8c3eVPiUqerReueE+yKHkbhKTJvKSiD0eAkRe6+WQ1FlmjQJWFgbdrw/ZszydGkXHIBQOpOXwR59y85B4HZvDll9w== s.ademoye16@gmail.com"
}

output "application_url" {
  value = "http://${aws_instance.todo_app.public_dns}"
}

output "instance_public_ip" {
  value = aws_instance.todo_app.public_ip
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/todo_app_key ubuntu@${aws_instance.todo_app.public_dns}"
}