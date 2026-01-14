# Bastion Host Security Group
resource "aws_security_group" "bastion" {
  name_description = "${var.project_name}-bastion-sg"
  description      = "Security group for SSH bastion host"
  vpc_id           = aws_vpc.main.id

  # SSH access - restrict to specific IP ranges
  ingress {
    description = "SSH from allowed IPs"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidr_blocks
  }

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-bastion-sg"
  }
}

# Private Instance Security Group (for instances in private subnets)
resource "aws_security_group" "private_instances" {
  name_description = "${var.project_name}-private-instances-sg"
  description      = "Security group for instances in private subnets"
  vpc_id           = aws_vpc.main.id

  # SSH from bastion only
  ingress {
    description     = "SSH from bastion host"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-private-instances-sg"
  }
}
