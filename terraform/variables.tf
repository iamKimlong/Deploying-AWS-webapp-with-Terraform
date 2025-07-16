variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "ap-southeast-1"  # Singapore region
}

variable "project_name" {
  description = "Cloud Computing Project"
  type        = string
  default     = "cloud-computing-project"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"  # 65,536 IP addresses
}

variable "public_subnet_1_cidr" {
  description = "CIDR block for public subnet 1"
  type        = string
  default     = "10.0.1.0/24"  # 256 IP addresses
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for public subnet 2"
  type        = string
  default     = "10.0.2.0/24"  # 256 IP addresses
}

# EC2 Configuration
variable "instance_type" {
  description = "EC2 instance type - t2.micro is free tier eligible"
  type        = string
  default     = "t2.micro"
  
  # Other options:
  # t2.nano   - 0.5 GB RAM (cheaper but less powerful)
  # t2.small  - 2 GB RAM (more expensive)
  # t3.micro  - 1 GB RAM (newer generation, better performance)
}

# Auto Scaling Configuration
variable "min_size" {
  description = "Minimum number of EC2 instances"
  type        = number
  default     = 2
  
  validation {
    condition     = var.min_size >= 1
    error_message = "Minimum size must be at least 1"
  }
}

variable "max_size" {
  description = "Maximum number of EC2 instances"
  type        = number
  default     = 4
  
  validation {
    condition     = var.max_size >= var.min_size
    error_message = "Maximum size must be greater than or equal to minimum size"
  }
}

variable "desired_capacity" {
  description = "Desired number of EC2 instances at launch"
  type        = number
  default     = 2
}

# Auto Scaling Thresholds
variable "scale_up_threshold" {
  description = "CPU percentage to trigger scale up"
  type        = number
  default     = 70
}

variable "scale_down_threshold" {
  description = "CPU percentage to trigger scale down"
  type        = number
  default     = 30
}

# CloudWatch Configuration
variable "log_retention_days" {
  description = "How many days to keep logs in CloudWatch"
  type        = number
  default     = 7
  
  # Valid values: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653
}

# Tags - Applied to all resources
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "CloudComputingCourse"
    ManagedBy   = "Terraform"
    Environment = "Development"
    Course      = "AWS-IaC"
  }
}
