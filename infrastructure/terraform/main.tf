terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Use a well-known Ubuntu 22.04 AMI ID for AWS Academy compatibility
locals {
  # Common Ubuntu 22.04 AMI IDs by region (AWS Academy compatible)
  ubuntu_amis = {
    "us-east-1"      = "ami-0e001c9271cf7f3b9"
    "us-west-2"      = "ami-017fecd1353bcc96e"
    "eu-central-1"   = "ami-06dd92ecc74fdfb36"
    "eu-west-1"      = "ami-0905a3c97561e0b69"
    "ap-southeast-1" = "ami-078c1149d8ad719a7"
    "ap-northeast-1" = "ami-09a81b370b76de6a2"
  }
  
  ubuntu_ami = lookup(local.ubuntu_amis, var.aws_region, "ami-0e001c9271cf7f3b9") # Default to us-east-1
}

# Generate SSH key pair for Ansible
resource "tls_private_key" "app_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create key pair for EC2 access (needed for Ansible)
resource "aws_key_pair" "app_key" {
  key_name   = "${var.project_name}-key-${random_id.key_suffix.hex}"
  public_key = tls_private_key.app_key.public_key_openssh

  tags = {
    Name = "${var.project_name}-key"
  }
}

# Generate random suffix for unique key name
resource "random_id" "key_suffix" {
  byte_length = 4
}

# Use the default VPC (AWS Academy restriction)
data "aws_vpc" "default" {
  default = true
}

# Use the default subnet (AWS Academy restriction)
data "aws_subnet" "default" {
  vpc_id            = data.aws_vpc.default.id
  default_for_az    = true
  availability_zone = "${var.aws_region}a"
}

# Create security group for the application
resource "aws_security_group" "app_sg" {
  name_prefix = "${var.project_name}-app-"
  vpc_id      = data.aws_vpc.default.id

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Application ports
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-app-sg"
  }
}

# Create EC2 instance
resource "aws_instance" "app_server" {
  ami                     = local.ubuntu_ami
  instance_type           = var.instance_type
  key_name                = aws_key_pair.app_key.key_name
  vpc_security_group_ids  = [aws_security_group.app_sg.id]
  subnet_id               = data.aws_subnet.default.id
  
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    docker_compose_version = var.docker_compose_version
  }))

  root_block_device {
    volume_type = "gp2"
    volume_size = var.volume_size
  }

  tags = {
    Name = "${var.project_name}-app-server"
  }
}

# Create Elastic IP
resource "aws_eip" "app_eip" {
  instance = aws_instance.app_server.id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-eip"
  }
} 