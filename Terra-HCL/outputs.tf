output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = aws_nat_gateway.main.id
}

output "nat_gateway_public_ip" {
  description = "Public IP of the NAT Gateway"
  value       = aws_eip.nat.public_ip
}

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

output "bastion_ssm_command" {
  description = "AWS CLI command to start a Session Manager shell"
  value       = "aws ssm start-session --target ${aws_instance.bastion.id} --region ${var.aws_region}"
}

output "sample_application_url" {
  description = "URL for the optional sample application"
  value       = var.enable_sample_application ? "http://${aws_lb.sample_application[0].dns_name}" : null
}

output "sample_database_endpoint" {
  description = "Endpoint for the optional private sample database"
  value       = var.enable_sample_database && var.enable_sample_application ? aws_db_instance.sample[0].address : null
}
