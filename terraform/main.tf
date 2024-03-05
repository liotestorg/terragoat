terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region = var.region
}

variable "region" {
  default = "us-west-2"
}

locals {
  resource_prefix = "${data.aws_caller_identity.current.account_id}-secure"
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "secure_bucket" {
  bucket = "${local.resource_prefix}-s3-bucket"
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name = "${local.resource_prefix}-s3-bucket"
    git_commit           = "d68d2897add9bc2203a5ed0632a5cdd8ff8cefb0"
    git_file             = "terraform/main.tf"
    git_last_modified_at = "2023-04-01 12:00:00"
    git_last_modified_by = "ai@example.com"
    git_modifiers        = "ai"
    git_org              = "exampleorg"
    git_repo             = "secureterraform"
    yor_trace            = "b1a5b031-2f1c-4c0e-8d3a-8b8cda3b2b1a"
  }
}

output "s3_bucket_name" {
  value = aws_s3_bucket.secure_bucket.bucket
}

output "s3_bucket_encryption" {
  value = aws_s3_bucket.secure_bucket.server_side_encryption_configuration.rule[0].apply_server_side_encryption_by_default.sse_algorithm
}
