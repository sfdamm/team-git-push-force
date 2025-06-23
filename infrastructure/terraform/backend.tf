# This file configures the Terraform backend for remote state storage
# The backend uses S3 for state storage and DynamoDB for state locking
# 
# Backend resources (S3 bucket and DynamoDB table) must be created first
# S3 bucket for state storage (created via setup-backend.sh)
# DynamoDB table for state locking (created via setup-backend.sh)

terraform {
  backend "s3" {
    # S3 bucket for state storage (created via setup-backend.sh)
    bucket = "concepter-terraform-state"
    
    # State file path - use workspaces for environment separation
    key = "infrastructure/terraform.tfstate"
    
    # AWS region for the S3 bucket
    region = "us-east-1"
    
    # DynamoDB table for state locking (created via setup-backend.sh)
    dynamodb_table = "concepter-terraform-locks"
    
    # Enable state file encryption
    encrypt = true
    
    # Optional: KMS key for additional encryption (comment out to use default)
    # kms_key_id = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
    
    # Workspace management
    workspace_key_prefix = "workspaces"
  }
} 