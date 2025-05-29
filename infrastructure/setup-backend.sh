#!/bin/bash

# Terraform Backend Setup Script
# This script creates the S3 bucket and DynamoDB table needed for Terraform state management
# Run this ONCE before using the main infrastructure deployment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Configuration
PROJECT_NAME=${1:-concepter}
AWS_REGION=${2:-us-east-1}

echo "=============================================="
echo "  Terraform Backend Setup for ${PROJECT_NAME}"
echo "=============================================="
echo ""
echo "Project: $PROJECT_NAME"
echo "Region: $AWS_REGION"
echo ""

# Check prerequisites
log_info "Checking prerequisites..."

if ! command -v terraform &> /dev/null; then
    log_error "Terraform is not installed. Please install Terraform first."
    exit 1
fi

if ! aws sts get-caller-identity &> /dev/null; then
    log_error "AWS credentials not configured. Please run 'aws configure' first."
    exit 1
fi

log_success "Prerequisites check passed!"

# Check if backend already exists
log_info "Checking if backend resources already exist..."

S3_BUCKET="${PROJECT_NAME}-terraform-state"
DYNAMODB_TABLE="${PROJECT_NAME}-terraform-locks"

if aws s3api head-bucket --bucket "$S3_BUCKET" 2>/dev/null; then
    log_warning "S3 bucket '$S3_BUCKET' already exists!"
    
    if aws dynamodb describe-table --table-name "$DYNAMODB_TABLE" --region "$AWS_REGION" 2>/dev/null; then
        log_warning "DynamoDB table '$DYNAMODB_TABLE' already exists!"
        log_info "Backend setup appears to be complete."
        
        read -p "Do you want to continue anyway? This will show the current configuration. [y/N]: " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Setup cancelled."
            exit 0
        fi
    fi
fi

# Create backend setup directory
SETUP_DIR="backend-setup"
mkdir -p "$SETUP_DIR"

# Create backend setup Terraform configuration
log_info "Creating backend setup configuration..."

cat > "$SETUP_DIR/main.tf" << EOF
# Backend Setup for Terraform State Management
# This creates the S3 bucket and DynamoDB table for remote state

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region for state backend"
  type        = string
  default     = "${AWS_REGION}"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "${PROJECT_NAME}"
}

# S3 bucket for Terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket = "\${var.project_name}-terraform-state"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "\${var.project_name}-terraform-state"
    Purpose     = "Terraform State Storage"
    Environment = "shared"
  }
}

# Enable versioning
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name           = "\${var.project_name}-terraform-locks"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "\${var.project_name}-terraform-locks"
    Purpose     = "Terraform State Locking"
    Environment = "shared"
  }
}

# Outputs
output "state_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "state_bucket_arn" {
  description = "ARN of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  value       = aws_dynamodb_table.terraform_locks.name
}

output "backend_config" {
  description = "Backend configuration for your terraform files"
  value = <<-EOT
    terraform {
      backend "s3" {
        bucket         = "\${aws_s3_bucket.terraform_state.bucket}"
        key            = "infrastructure/terraform.tfstate"
        region         = "${AWS_REGION}"
        dynamodb_table = "\${aws_dynamodb_table.terraform_locks.name}"
        encrypt        = true
      }
    }
  EOT
}
EOF

# Run Terraform
log_info "Initializing Terraform for backend setup..."
cd "$SETUP_DIR"

terraform init

log_info "Planning backend setup..."
terraform plan -out=tfplan

log_info "Applying backend setup..."
terraform apply -auto-approve tfplan

# Get outputs
log_success "Backend setup completed!"
echo ""
log_info "Backend Configuration:"
terraform output -raw backend_config

echo ""
log_success "✅ Backend setup complete!"
log_info "S3 Bucket: $(terraform output -raw state_bucket_name)"
log_info "DynamoDB Table: $(terraform output -raw dynamodb_table_name)"

# Cleanup
cd ..
log_info "Cleaning up temporary files..."
rm -rf "$SETUP_DIR"

echo ""
log_success "🎉 Terraform backend is now ready!"
echo ""
log_info "Next steps:"
echo "1. Your main Terraform configuration is already configured to use this backend"
echo "2. Run your normal deployment: ./deploy.sh or use GitHub Actions"
echo "3. Each environment will use separate workspaces for isolation" 