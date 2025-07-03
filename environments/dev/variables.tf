variable "project_name" {
  description = "The name of the project"
  type        = string
  default = "flask_app"
}

variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "key_name" {
  description = "Name of the SSH key pair to use for EC2 instances"
  type        = string
}

variable "db_name" {
  description = "Name of the RDS database"
  type        = string
  default     = "flaskdb"
}

variable "db_username" {
  description = "Username for the RDS database"
  type        = string
  default     = "admin"
}

