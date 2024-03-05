variable "region" {
  default = "us-west-2"
}

locals {
  resource_prefix = "${data.aws_caller_identity.current.account_id}-module2"
}

resource "aws_kms_key" "cloudtrail_logs_key" {
  description             = "${local.resource_prefix}-cloudtrail-logs-key"
  enable_key_rotation     = true
  deletion_window_in_days = 10
  tags = {
    Name = "${local.resource_prefix}-cloudtrail-logs-key"
  }
}

resource "aws_cloudwatch_log_group" "cloudtrail_logs" {
  name              = "${local.resource_prefix}-cloudtrail-logs"
  retention_in_days = 90
  kms_key_id        = aws_kms_key.cloudtrail_logs_key.arn
  tags = {
    Name = "${local.resource_prefix}-cloudtrail-logs"
  }
}

resource "aws_cloudtrail" "cloudtrail_logging" {
  name                          = "${local.resource_prefix}-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs_bucket.bucket
  cloud_watch_logs_group_arn    = aws_cloudwatch_log_group.cloudtrail_logs.arn
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_logging_role.arn
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true
  kms_key_id                    = aws_kms_key.cloudtrail_logs_key.arn
  tags = {
    Name = "${local.resource_prefix}-cloudtrail"
  }
}

resource "aws_s3_bucket" "cloudtrail_logs_bucket" {
  bucket = "${local.resource_prefix}-cloudtrail-logs"
  acl    = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
        kms_master_key_id = aws_kms_key.cloudtrail_logs_key.arn
      }
    }
  }
  tags = {
    Name = "${local.resource_prefix}-cloudtrail-logs-bucket"
  }
  public_access_block_configuration {
    block_public_acls   = true
    ignore_public_acls  = true
    block_public_policy = true
    restrict_public_buckets = true
  }
}

resource "aws_iam_role" "cloudtrail_logging_role" {
  name = "${local.resource_prefix}-cloudtrail-logging-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

  tags = {
    Name = "${local.resource_prefix}-cloudtrail-logging-role"
  }
}

resource "aws_iam_role_policy" "cloudtrail_logging_policy" {
  name = "${local.resource_prefix}-cloudtrail-logging-policy"
  role = aws_iam_role.cloudtrail_logging_role.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream"
      ],
      "Resource": [
        "${aws_cloudwatch_log_group.cloudtrail_logs.arn}"
      ]
    }
  ]
}
POLICY
}

output "cloudtrail_log_group_name" {
  value = aws_cloudwatch_log_group.cloudtrail_logs.name
}

output "cloudtrail_name" {
  value = aws_cloudtrail.cloudtrail_logging.name
}

output "cloudtrail_logs_bucket_name" {
  value = aws_s3_bucket.cloudtrail_logs_bucket.bucket
}
