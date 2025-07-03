variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (dev/prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
  
}

variable "security_group_id" {
  description = "ID of the security group for the Auto Scaling group"
  type        = string
  
}

variable "instance_type" {
  description = "Instance type for the Auto Scaling group"
  type        = string
}

variable "key_name" {
  description = "Name of the key pair for the EC2 instances"
  type        = string
}

variable "min_size" {
  description = "Minimum size of the Auto Scaling group"
  type        = number
}

variable "max_size" {
  description = "Maximum size of the Auto Scaling group"
  type        = number
}

variable "desired_capacity" {
  description = "Desired capacity of the Auto Scaling group"
  type        = number
}

variable "db_endpoint" {
  description = "Endpoint of the RDS database"
  type        = string  
}

variable "db_name" {
  description = "Name of the RDS database"
  type        = string
}

variable "db_password_secret_arn" {
  description = "ARN of the AWS Secrets Manager secret containing the RDS database password"
  type        = string
}

variable "db_username_secret_arn" {
  description = "ARN of the secret for the database username"
  type        = string
}

variable "flask_secret_key_secret_arn" {
  description = "ARN of the secret for the Flask secret key"
  type        = string
}

variable "photos_bucket" {
  description = "Name of the S3 bucket for photos"
  type        = string
}

variable "alb_security_group_id" {
  description = "ID of the ALB security group"
  type        = string
}
