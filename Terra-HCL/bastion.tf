data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
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

resource "aws_iam_role" "bastion" {
  name = "${var.project_name}-bastion-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "bastion_ssm" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${var.project_name}-bastion-profile"
  role = aws_iam_role.bastion.name
}

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.bastion_instance_type
  subnet_id              = var.assign_eip_to_bastion ? aws_subnet.public[0].id : aws_subnet.private[0].id
  vpc_security_group_ids = [aws_security_group.bastion.id]
  iam_instance_profile   = aws_iam_instance_profile.bastion.name
  monitoring             = true

  disable_api_termination = var.environment == "production" ? true : false

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 8
    delete_on_termination = true
    encrypted             = true
  }

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y htop vim tmux
              systemctl enable --now amazon-ssm-agent
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

resource "aws_eip" "bastion" {
  count = var.assign_eip_to_bastion ? 1 : 0

  instance = aws_instance.bastion.id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-bastion-eip"
  }

  depends_on = [aws_internet_gateway.main]
}
