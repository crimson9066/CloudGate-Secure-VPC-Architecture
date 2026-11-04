data "aws_caller_identity" "current" {}

resource "aws_guardduty_detector" "this" {
  count  = var.enable_security_services ? 1 : 0
  enable = true
}

resource "aws_securityhub_account" "this" {
  count                    = var.enable_security_services ? 1 : 0
  enable_default_standards = true
  depends_on               = [aws_guardduty_detector.this]
}

resource "aws_iam_role" "config" {
  count = var.enable_security_services ? 1 : 0
  name  = "${var.project_name}-config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "config.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "config" {
  count      = var.enable_security_services ? 1 : 0
  role       = aws_iam_role.config[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

resource "aws_s3_bucket" "config" {
  count  = var.enable_security_services ? 1 : 0
  bucket = "${var.project_name}-${data.aws_caller_identity.current.account_id}-config"
}

resource "aws_s3_bucket_public_access_block" "config" {
  count                   = var.enable_security_services ? 1 : 0
  bucket                  = aws_s3_bucket.config[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "config" {
  count  = var.enable_security_services ? 1 : 0
  bucket = aws_s3_bucket.config[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "config" {
  count  = var.enable_security_services ? 1 : 0
  bucket = aws_s3_bucket.config[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AWSConfigBucketPermissionsCheck"
      Effect    = "Allow"
      Principal = { Service = "config.amazonaws.com" }
      Action    = "s3:GetBucketAcl"
      Resource  = aws_s3_bucket.config[0].arn
      Condition = { StringEquals = { "AWS:SourceAccount" = data.aws_caller_identity.current.account_id } }
      }, {
      Sid       = "AWSConfigBucketDelivery"
      Effect    = "Allow"
      Principal = { Service = "config.amazonaws.com" }
      Action    = "s3:PutObject"
      Resource  = "${aws_s3_bucket.config[0].arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/Config/*"
      Condition = {
        StringEquals = {
          "s3:x-amz-acl"      = "bucket-owner-full-control"
          "AWS:SourceAccount" = data.aws_caller_identity.current.account_id
        }
      }
    }]
  })
}

resource "aws_config_delivery_channel" "this" {
  count          = var.enable_security_services ? 1 : 0
  name           = "${var.project_name}-config-delivery"
  s3_bucket_name = aws_s3_bucket.config[0].bucket
}

resource "aws_config_configuration_recorder" "this" {
  count    = var.enable_security_services ? 1 : 0
  name     = "${var.project_name}-configuration-recorder"
  role_arn = aws_iam_role.config[0].arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_configuration_recorder_status" "this" {
  count      = var.enable_security_services ? 1 : 0
  name       = aws_config_configuration_recorder.this[0].name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.this]
}
