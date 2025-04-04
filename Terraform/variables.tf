variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "ecr_repository_url" {
  description = "The URL of the ECR repository for Medusa"
  type        = string
}

variable "db_password" {
  description = "The password for the RDS PostgreSQL database"
  type        = string
  sensitive   = true
}
