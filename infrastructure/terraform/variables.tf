variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "concepter"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 10
}

variable "docker_compose_version" {
  description = "Docker Compose version to install"
  type        = string
  default     = "2.24.0"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
} 