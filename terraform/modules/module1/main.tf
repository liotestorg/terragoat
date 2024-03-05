variable "region" {
  default = "us-west-2"
}

locals {
  resource_prefix = {
    value = "module1-secure"
  }
}
resource "aws_kms_key" "s3_encryption_key" {
  description             = "KMS key for encrypting S3 data"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  policy                  = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "key-default-1",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::123456789012:root"
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Allow use of the key",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::123456789012:user/specific-user-1",
          "arn:aws:iam::123456789012:user/specific-user-2"
        ]
      },
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": "*"
    },
    {
      "Sid": "Allow attachment of persistent resources",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::123456789012:user/specific-user-1",
          "arn:aws:iam::123456789012:user/specific-user-2"
        ]
      },
      "Action": [
        "kms:CreateGrant",
        "kms:ListGrants",
        "kms:RevokeGrant"
      ],
      "Resource": "*",
      "Condition": {
        "Bool": {
          "kms:GrantIsForAWSResource": "true"
        }
      }
    }
  ]
}
POLICY

  tags = {
    Name                  = "${local.resource_prefix.value}-s3-encryption-key"
    git_commit            = "fix_security_issue"
    git_file              = "terraform/modules/module1/main.tf"
    git_last_modified_at  = "2023-04-01"
    git_last_modified_by  = "senior_software_engineer"
    git_modifiers         = "senior_software_engineer"
    git_org               = "your_org"
    git_repo              = "your_repo"
    yor_trace             = "unique_trace_id_for_encryption_key"
  }
}

resource "aws_s3_bucket" "secure_bucket" {
  bucket = "${local.resource_prefix.value}-secure-bucket"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_key.s3_encryption_key.arn
      }
    }
  }

  tags = {
    Name                  = "${local.resource_prefix.value}-secure-bucket"
    git_commit            = "fix_security_issue"
    git_file              = "terraform/modules/module1/main.tf"
    git_last_modified_at  = "2023-04-01"
    git_last_modified_by  = "senior_software_engineer"
    git_modifiers         = "senior_software_engineer"
    git_org               = "your_org"
    git_repo              = "your_repo"
    yor_trace             = "unique_trace_id_for_bucket"
  }
}

output "secure_bucket_name" {
  value = aws_s3_bucket.secure_bucket.bucket
}

output "secure_bucket_encryption_key" {
  value = aws_kms_key.s3_encryption_key.arn
}
