#!/bin/bash

# Concepter Infrastructure Deployment Script
# This script deploys the infrastructure using Terraform and Ansible

set -e

# Configuration
ENVIRONMENT=${1:-staging}
ACTION=${2:-apply}
SKIP_ANSIBLE=${3:-false}

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

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    if ! command -v terraform &> /dev/null; then
        log_error "Terraform is not installed. Please install Terraform first."
        exit 1
    fi
    
    if ! command -v ansible &> /dev/null && [ "$SKIP_ANSIBLE" != "true" ]; then
        log_error "Ansible is not installed. Please install Ansible first."
        exit 1
    fi
    
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS credentials not configured. Please run 'aws configure' first."
        exit 1
    fi
    
    log_success "Prerequisites check passed!"
}

# Deploy Terraform
deploy_terraform() {
    log_info "Starting Terraform deployment..."
    
    cd terraform
    
    # Format check
    log_info "Checking Terraform formatting..."
    terraform fmt -check -recursive || {
        log_warning "Terraform files are not properly formatted. Running terraform fmt..."
        terraform fmt -recursive
    }
    
    # Initialize
    log_info "Initializing Terraform..."
    terraform init
    
    # Validate
    log_info "Validating Terraform configuration..."
    terraform validate
    
    # Plan
    log_info "Creating Terraform plan..."
    terraform plan \
        -var="environment=${ENVIRONMENT}" \
        -var="project_name=concepter-${ENVIRONMENT}" \
        -out=tfplan
    
    if [ "$ACTION" = "plan" ]; then
        log_success "Terraform plan completed successfully!"
        cd ..
        return 0
    fi
    
    if [ "$ACTION" = "destroy" ]; then
        log_warning "Destroying infrastructure..."
        terraform destroy -auto-approve \
            -var="environment=${ENVIRONMENT}" \
            -var="project_name=concepter-${ENVIRONMENT}"
        log_success "Infrastructure destroyed successfully!"
        cd ..
        return 0
    fi
    
    # Apply
    log_info "Applying Terraform changes..."
    terraform apply -auto-approve tfplan
    
    # Get outputs
    log_info "Retrieving Terraform outputs..."
    INSTANCE_IP=$(terraform output -raw instance_public_ip)
    KEY_NAME=$(terraform output -raw key_pair_name)
    
    # Save outputs for Ansible
    mkdir -p ../ansible/artifacts
    terraform output -raw private_key > ../ansible/artifacts/private_key.pem
    chmod 600 ../ansible/artifacts/private_key.pem
    echo "$INSTANCE_IP" > ../ansible/artifacts/instance_ip.txt
    
    log_success "Terraform deployment completed successfully!"
    log_info "Instance IP: $INSTANCE_IP"
    
    cd ..
    
    # Export for Ansible
    export INSTANCE_IP
    export KEY_NAME
}

# Deploy with Ansible
deploy_ansible() {
    if [ "$SKIP_ANSIBLE" = "true" ]; then
        log_info "Skipping Ansible deployment as requested."
        return 0
    fi
    
    log_info "Starting Ansible deployment..."
    
    cd ansible
    
    # Check if we have the required files
    if [ ! -f "artifacts/instance_ip.txt" ] || [ ! -f "artifacts/private_key.pem" ]; then
        log_error "Terraform outputs not found. Please run Terraform first."
        exit 1
    fi
    
    INSTANCE_IP=$(cat artifacts/instance_ip.txt)
    
    # Create dynamic inventory
    log_info "Creating Ansible inventory..."
    cat > inventory.ini << EOF
[app_server]
concepter-server ansible_host=${INSTANCE_IP} ansible_user=ubuntu ansible_ssh_private_key_file=artifacts/private_key.pem ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOF
    
    # Wait for instance to be ready
    log_info "Waiting for instance to be ready..."
    for i in {1..30}; do
        if ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -i artifacts/private_key.pem ubuntu@${INSTANCE_IP} 'echo "Instance ready"' &> /dev/null; then
            log_success "Instance is ready!"
            break
        fi
        log_info "Attempt $i: Instance not ready yet, waiting..."
        sleep 10
    done
    
    # Test connection
    log_info "Testing Ansible connection..."
    export ANSIBLE_HOST_KEY_CHECKING=False
    ansible all -i inventory.ini -m ping --timeout=30
    
    # Run playbook
    log_info "Running Ansible playbook..."
    ansible-playbook -i inventory.ini playbook.yml \
        --extra-vars "github_actor=${USER}" \
        --extra-vars "github_token=${GITHUB_TOKEN:-}" \
        --extra-vars "environment=${ENVIRONMENT}" \
        -v
    
    # Verify deployment
    log_info "Verifying deployment..."
    sleep 30
    for i in {1..10}; do
        if curl -f "http://${INSTANCE_IP}:3000" > /dev/null 2>&1; then
            log_success "Application is responding successfully!"
            break
        fi
        log_info "Attempt $i: Application not ready yet, waiting..."
        sleep 15
    done
    
    cd ..
    
    log_success "Ansible deployment completed successfully!"
    log_success "🌐 Application URL: http://${INSTANCE_IP}:3000"
    log_success "⚙️  API Gateway: http://${INSTANCE_IP}:8080"
}

# Cleanup function
cleanup() {
    log_info "Cleaning up temporary files..."
    rm -f ansible/artifacts/private_key.pem
    rm -f ansible/artifacts/instance_ip.txt
    rm -f ansible/inventory.ini
}

# Main execution
main() {
    echo "========================================="
    echo "  Concepter Infrastructure Deployment  "
    echo "========================================="
    echo ""
    echo "Environment: $ENVIRONMENT"
    echo "Action: $ACTION"
    echo "Skip Ansible: $SKIP_ANSIBLE"
    echo ""
    
    # Set trap for cleanup
    trap cleanup EXIT
    
    check_prerequisites
    deploy_terraform
    
    if [ "$ACTION" = "apply" ]; then
        deploy_ansible
    fi
    
    log_success "Deployment completed successfully! 🎉"
}

# Usage information
usage() {
    echo "Usage: $0 [environment] [action] [skip_ansible]"
    echo ""
    echo "Arguments:"
    echo "  environment    Environment to deploy (staging|production) [default: staging]"
    echo "  action         Terraform action (plan|apply|destroy) [default: apply]"
    echo "  skip_ansible   Skip Ansible deployment (true|false) [default: false]"
    echo ""
    echo "Examples:"
    echo "  $0                           # Deploy staging environment"
    echo "  $0 production                # Deploy production environment"
    echo "  $0 staging plan              # Plan staging deployment"
    echo "  $0 staging apply true        # Deploy staging without Ansible"
    echo "  $0 production destroy        # Destroy production environment"
    echo ""
    echo "Prerequisites:"
    echo "  - Terraform installed"
    echo "  - Ansible installed"
    echo "  - AWS CLI configured"
    echo "  - GITHUB_TOKEN environment variable (optional, for private registries)"
}

# Parse arguments
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    usage
    exit 0
fi

# Run main function
main 