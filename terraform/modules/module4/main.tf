variable "region" {
  default = "us-west-2"
}

provider "aws" {
  region = var.region
}

locals {
  resource_prefix = "${data.aws_caller_identity.current.account_id}-module4"
}

resource "aws_secretsmanager_secret" "db_password" {
  name                    = "${local.resource_prefix}-db-password"
  recovery_window_in_days = 7
  description             = "Database password for application"
}

resource "aws_secretsmanager_secret_version" "db_password_version" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = var.password
}

resource "aws_iam_policy" "secretsmanager_policy" {
  name        = "${local.resource_prefix}-secretsmanager-policy"
  path        = "/"
  description = "IAM policy for accessing secrets in AWS Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = "secretsmanager:GetSecretValue"
        Resource  = aws_secretsmanager_secret.db_password.arn
        Principal = { AWS = ["arn:aws:iam::123456789012:role/AuthorizedRole"] }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "secretsmanager_policy_attachment" {
  role       = aws_iam_role.iam_for_module4.name
  policy_arn = aws_iam_policy.secretsmanager_policy.arn
}

resource "aws_iam_role" "iam_for_module4" {
  name               = "${local.resource_prefix}-iam-for-module4"
  assume_role_policy = data.aws_iam_policy_document.iam_policy_module4.json
  tags = {
    git_commit           = "replace_with_actual_git_commit"
    git_file             = "terraform/modules/module4/main.tf"
    git_last_modified_at = "replace_with_actual_last_modified_date"
    git_last_modified_by = "replace_with_actual_modifier_email"
    git_modifiers        = "replace_with_actual_modifiers"
    git_org              = "replace_with_actual_org"
    git_repo             = "replace_with_actual_repo"
    yor_trace            = "replace_with_actual_yor_trace"
  }
}

data "aws_iam_policy_document" "iam_policy_module4" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

output "db_password_secret_arn" {
  description = "The ARN of the database password secret in AWS Secrets Manager"
  value       = aws_secretsmanager_secret.db_password.arn
}

output "db_password_secret_name" {
  description = "The name of the database password secret in AWS Secrets Manager"
  value       = aws_secretsmanager_secret.db_password.name
}
