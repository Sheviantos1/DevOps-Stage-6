variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "domain" {
  description = "Domain name for the application"
  type        = string
}

variable "email" {
  description = "Email for SSL certificates"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository URL"
  type        = string
}

