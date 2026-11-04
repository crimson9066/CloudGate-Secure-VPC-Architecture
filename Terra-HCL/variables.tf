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
  description = "Deprecated compatibility variable; SSH access is disabled"
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.allowed_ssh_cidr_blocks) == 0
    error_message = "Public SSH is intentionally disabled. Use AWS Systems Manager Session Manager."
  }
}

variable "bastion_instance_type" {
  description = "Instance type for bastion host"
  type        = string
  default     = "t3.micro"
}

variable "bastion_public_key" {
  description = "Deprecated compatibility variable; SSH access is disabled"
  type        = string
  default     = ""
}

variable "assign_eip_to_bastion" {
  description = "Whether to assign an Elastic IP to the SSM-managed bastion host"
  type        = bool
  default     = false
}

variable "enable_vpc_flow_logs" {
  description = "Enable VPC Flow Logs to CloudWatch Logs"
  type        = bool
  default     = false
}

variable "enable_security_services" {
  description = "Enable opt-in account-level AWS security services"
  type        = bool
  default     = false
}

variable "enable_cloudtrail" {
  description = "Enable an opt-in regional CloudTrail trail with encrypted S3 delivery"
  type        = bool
  default     = false
}

variable "enable_ssm_vpc_endpoints" {
  description = "Create private VPC endpoints for Systems Manager"
  type        = bool
  default     = false
}

variable "enable_sample_application" {
  description = "Deploy the optional ALB and Auto Scaling sample application"
  type        = bool
  default     = false
}

variable "enable_sample_database" {
  description = "Deploy an optional encrypted PostgreSQL database for the sample application"
  type        = bool
  default     = false
}

variable "sample_database_instance_class" {
  description = "RDS instance class for the optional sample database"
  type        = string
  default     = "db.t3.micro"
}

variable "sample_application_instance_type" {
  description = "Instance type for the optional sample application"
  type        = string
  default     = "t3.micro"
}

variable "sample_application_min_size" {
  description = "Minimum number of sample application instances"
  type        = number
  default     = 2
}

variable "sample_application_max_size" {
  description = "Maximum number of sample application instances"
  type        = number
  default     = 4
}
