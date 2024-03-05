variable "region" {
  default = "us-west-2"
}

data "aws_caller_identity" "current" {}

locals {
  resource_prefix = "${data.aws_caller_identity.current.account_id}-module3"
}

# Create a more secure VPC configuration
resource "aws_vpc" "secure_vpc" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.resource_prefix}-secure-vpc"
  }
}

# Create subnets with Network ACLs for tighter network security
resource "aws_subnet" "secure_subnet1" {
  vpc_id            = aws_vpc.secure_vpc.id
  cidr_block        = "10.20.1.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name = "${local.resource_prefix}-secure-subnet1"
  }
}

resource "aws_network_acl" "secure_nacl" {
  vpc_id = aws_vpc.secure_vpc.id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  egress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  tags = {
    Name = "${local.resource_prefix}-secure-nacl"
  }
}

# Attach the NACL to the subnet
resource "aws_network_acl_association" "secure_nacl_association" {
  network_acl_id = aws_network_acl.secure_nacl.id
  subnet_id      = aws_subnet.secure_subnet1.id
}

# Output the secure VPC and subnet IDs
output "secure_vpc_id" {
  value = aws_vpc.secure_vpc.id
}

output "secure_subnet1_id" {
  value = aws_subnet.secure_subnet1.id
}
