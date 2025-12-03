[app_servers]
app_server ansible_host=${server_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/${ssh_key}.pem ansible_ssh_common_args='-o StrictHostKeyChecking=no'