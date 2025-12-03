# Data source for latest Ubuntu AMI
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

# Security Group
resource "aws_security_group" "app_sg" {
  name        = "devops-stage6-sg"
  description = "Security group for DevOps Stage 6 application"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = {
    Name = "devops-stage6-sg"
  }
}

# EC2 Instance
resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "devops-stage6-server"
  }

  lifecycle {
    ignore_changes = [ami]
  }
}

# Generate Ansible Inventory
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tpl", {
    server_ip = aws_instance.app_server.public_ip
    ssh_key   = var.key_name
  })
  filename = "${path.module}/../ansible/inventory/hosts"

  depends_on = [aws_instance.app_server]
}

# Execute Ansible Playbook
resource "null_resource" "run_ansible" {
  triggers = {
    instance_id = aws_instance.app_server.id
    always_run  = timestamp()
  }

  provisioner "local-exec" {
    command = <<-EOT
      sleep 90
      cd ${path.module}/../ansible && \
      ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
        -i inventory/hosts playbook.yml \
        --extra-vars "github_repo=https://github.com/Sheviantos1/DevOps-Stage-6.git domain=shevytodonew.mooo.com email=s.ademoye16@gmail.com"
    EOT
  }

  depends_on = [
    local_file.ansible_inventory,
    aws_instance.app_server
  ]
}