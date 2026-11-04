locals {
  sample_database_enabled = var.enable_sample_database && var.enable_sample_application
}

resource "aws_security_group" "database" {
  count       = local.sample_database_enabled ? 1 : 0
  name        = "${var.project_name}-database-sg"
  description = "Database accepts PostgreSQL only from application instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "PostgreSQL from application tier"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.application[0].id]
  }

  egress {
    description = "Allow database response traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "terraform_data" "sample_database_requires_application" {
  input = var.enable_sample_database

  lifecycle {
    precondition {
      condition     = !var.enable_sample_database || var.enable_sample_application
      error_message = "enable_sample_application must be true when enable_sample_database is enabled."
    }
  }
}

resource "aws_db_subnet_group" "sample" {
  count      = local.sample_database_enabled ? 1 : 0
  name       = "${var.project_name}-database"
  subnet_ids = aws_subnet.private[*].id
}

resource "random_password" "database" {
  count            = local.sample_database_enabled ? 1 : 0
  length           = 32
  special          = true
  override_special = "!#$%&()*+,-.:;<=>?[]^_{|}~"
}

resource "aws_secretsmanager_secret" "database" {
  count = local.sample_database_enabled ? 1 : 0
  name  = "${var.project_name}/database-credentials"
}

resource "aws_secretsmanager_secret_version" "database" {
  count     = local.sample_database_enabled ? 1 : 0
  secret_id = aws_secretsmanager_secret.database[0].id
  secret_string = jsonencode({
    username = "cloudgate"
    password = random_password.database[0].result
  })
}

resource "aws_db_instance" "sample" {
  count                   = local.sample_database_enabled ? 1 : 0
  identifier              = "${var.project_name}-database"
  engine                  = "postgres"
  engine_version          = "16"
  instance_class          = var.sample_database_instance_class
  allocated_storage       = 20
  max_allocated_storage   = 100
  storage_encrypted       = true
  db_name                 = "cloudgate"
  username                = "cloudgate"
  password                = random_password.database[0].result
  port                    = 5432
  db_subnet_group_name    = aws_db_subnet_group.sample[0].name
  vpc_security_group_ids  = [aws_security_group.database[0].id]
  publicly_accessible     = false
  backup_retention_period = 7
  skip_final_snapshot     = true
  deletion_protection     = var.environment == "production"
}
