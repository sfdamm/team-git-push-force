output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_eip.app_eip.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.app_server.private_ip
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "ID of the public subnet"
  value       = data.aws_subnet.default.id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.app_sg.id
}

output "key_pair_name" {
  description = "Name of the key pair"
  value       = aws_key_pair.app_key.key_name
}

output "client_url" {
  description = "URL for the client application"
  value       = "https://client.${aws_eip.app_eip.public_ip}.nip.io"
}

output "api_url" {
  description = "URL for the API"
  value       = "https://api.${aws_eip.app_eip.public_ip}.nip.io/api"
}

output "ssh_public_key" {
  description = "SSH public key"
  value       = tls_private_key.app_key.public_key_openssh
}

# Alias for GitHub Actions workflow compatibility
output "private_key" {
  description = "SSH private key for Ansible (alias for ssh_private_key)"
  value       = tls_private_key.app_key.private_key_pem
  sensitive   = true
}