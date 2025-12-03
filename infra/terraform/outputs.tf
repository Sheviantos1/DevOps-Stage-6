output "server_public_ip" {
  description = "Public IP of the application server"
  value       = aws_instance.app_server.public_ip
}

output "server_id" {
  description = "Instance ID"
  value       = aws_instance.app_server.id
}