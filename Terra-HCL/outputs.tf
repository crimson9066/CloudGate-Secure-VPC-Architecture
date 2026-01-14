# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

# Subnet Outputs
output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = aws_subnet.private[*].id
}

# NAT Gateway Outputs
output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = aws_nat_gateway.main.id
}

output "nat_gateway_public_ip" {
  description = "Public IP of the NAT Gateway"
  value       = aws_eip.nat.public_ip
}

# Bastion Host Outputs
output "bastion_instance_id" {
  description = "Instance ID of the bastion host"
  value       = aws_instance.bastion.id
}

output "bastion_public_ip" {
  description = "Public IP address of the bastion host"
  value       = var.assign_eip_to_bastion ? aws_eip.bastion[0].public_ip : aws_instance.bastion.public_ip
}

output "bastion_private_ip" {
  description = "Private IP address of the bastion host"
  value       = aws_instance.bastion.private_ip
}

output "bastion_security_group_id" {
  description = "Security group ID of the bastion host"
  value       = aws_security_group.bastion.id
}

output "private_instances_security_group_id" {
  description = "Security group ID for private instances"
  value       = aws_security_group.private_instances.id
}

# Connection Information
output "bastion_ssh_command" {
  description = "SSH command to connect to bastion host"
  value       = "ssh -i ~/.ssh/your-key.pem ec2-user@${var.assign_eip_to_bastion ? aws_eip.bastion[0].public_ip : aws_instance.bastion.public_ip}"
}
