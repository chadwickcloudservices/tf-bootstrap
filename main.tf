terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.20.1"
    }
  }
  required_version = "~> 1.5.0"
}

provider "aws" {
  # Configuration options
}

resource "aws_s3_bucket" "backend" {
  tags = {
    Name        = "backend_bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_versioning" "backend" {
  bucket = aws_s3_bucket.backend.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Resource to avoid error "AccessControlListNotSupported: The bucket does not allow ACLs"
resource "aws_s3_bucket_ownership_controls" "backend" {
  bucket = aws_s3_bucket.backend.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_acl" "backend" {
  bucket     = aws_s3_bucket.backend.id
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.backend]
}

resource "aws_dynamodb_table" "backend" {
  name           = "terraform_state"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    "Name" = "Terraform State Lock Table"
  }
}