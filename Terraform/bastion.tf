# Data source to get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# SSH Key Pair
resource "aws_key_pair" "bastion" {
  key_name   = "${var.project_name}-bastion-key"
  public_key = var.bastion_public_key

  tags = {
    Name = "${var.project_name}-bastion-key"
  }
}

# Bastion Host Instance
resource "aws_instance" "bastion" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.bastion_instance_type
  subnet_id     = aws_subnet.public[0].id

  vpc_security_group_ids = [aws_security_group.bastion.id]
  key_name               = aws_key_pair.bastion.key_name

  # Enable detailed monitoring
  monitoring = true

  # Enable termination protection for production
  disable_api_termination = var.environment == "production" ? true : false

  # Root volume configuration
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 8
    delete_on_termination = true
    encrypted             = true
  }

  # User data script for initial setup
  user_data = <<-EOF
              #!/bin/bash
              # Update system packages
              yum update -y
              
              # Install essential tools
              yum install -y htop vim tmux
              
              # Configure automatic security updates
              yum install -y yum-cron
              systemctl enable yum-cron
              systemctl start yum-cron
              
              # Harden SSH configuration
              sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
              sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
              systemctl restart sshd
              
              # Set hostname
              hostnamectl set-hostname ${var.project_name}-bastion
              EOF

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = {
    Name = "${var.project_name}-bastion"
    Role = "Bastion"
  }
}

# Elastic IP for Bastion (optional - for static IP)
resource "aws_eip" "bastion" {
  count = var.assign_eip_to_bastion ? 1 : 0

  instance = aws_instance.bastion.id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-bastion-eip"
  }

  depends_on = [aws_internet_gateway.main]
}
