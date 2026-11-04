data "aws_ami" "sample_application" {
  count       = var.enable_sample_application ? 1 : 0
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
}

resource "aws_security_group" "alb" {
  count       = var.enable_sample_application ? 1 : 0
  name        = "${var.project_name}-alb-sg"
  description = "Public HTTPS entry point for the sample application"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP demo traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "application" {
  count       = var.enable_sample_application ? 1 : 0
  name        = "${var.project_name}-application-sg"
  description = "Application instances accept traffic only from the ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb[0].id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "sample_application" {
  count = var.enable_sample_application ? 1 : 0
  name  = "${var.project_name}-application-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "sample_application_ssm" {
  count      = var.enable_sample_application ? 1 : 0
  role       = aws_iam_role.sample_application[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "sample_application" {
  count = var.enable_sample_application ? 1 : 0
  name  = "${var.project_name}-application-profile"
  role  = aws_iam_role.sample_application[0].name
}

resource "aws_launch_template" "sample_application" {
  count         = var.enable_sample_application ? 1 : 0
  name_prefix   = "${var.project_name}-application-"
  image_id      = data.aws_ami.sample_application[0].id
  instance_type = var.sample_application_instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.sample_application[0].name
  }

  vpc_security_group_ids = [aws_security_group.application[0].id]

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    dnf install -y nginx
    cat > /usr/share/nginx/html/index.html <<'HTML'
    <html><body><h1>CloudGate secure sample application</h1><p>Served from a private subnet.</p></body></html>
    HTML
    systemctl enable --now nginx
  EOF
  )
}

resource "aws_lb" "sample_application" {
  count              = var.enable_sample_application ? 1 : 0
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb[0].id]
  subnets            = aws_subnet.public[*].id
}

resource "aws_lb_target_group" "sample_application" {
  count    = var.enable_sample_application ? 1 : 0
  name     = "${var.project_name}-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "sample_application" {
  count             = var.enable_sample_application ? 1 : 0
  load_balancer_arn = aws_lb.sample_application[0].arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sample_application[0].arn
  }
}

resource "aws_autoscaling_group" "sample_application" {
  count               = var.enable_sample_application ? 1 : 0
  name                = "${var.project_name}-application"
  min_size            = var.sample_application_min_size
  max_size            = var.sample_application_max_size
  desired_capacity    = var.sample_application_min_size
  vpc_zone_identifier = aws_subnet.private[*].id
  target_group_arns   = [aws_lb_target_group.sample_application[0].arn]
  health_check_type   = "ELB"

  launch_template {
    id      = aws_launch_template.sample_application[0].id
    version = "$Latest"
  }
}
