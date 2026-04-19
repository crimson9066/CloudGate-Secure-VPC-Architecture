variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "me-south-1" # Bahrain - closest to Egypt
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "cloudgate"
}

variable "environment" {
  description = "Environment (dev, staging, production)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["me-south-1a", "me-south-1b", "me-south-1c"]
}

variable "allowed_ssh_cidr_blocks" {
  description = "CIDR blocks allowed to SSH into bastion host"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "bastion_instance_type" {
  description = "Instance type for bastion host"
  type        = string
  default     = "t3.micro"
}

variable "bastion_public_key" {
  description = "Public SSH key for bastion host access"
  type        = string
}

variable "assign_eip_to_bastion" {
  description = "Whether to assign an Elastic IP to the bastion host"
  type        = bool
  default     = true
}
