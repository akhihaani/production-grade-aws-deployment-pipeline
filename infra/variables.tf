variable "region" {
  type        = string
  description = "AWS region to deploy into"
}

variable "account_id" {
  type        = string
  description = "AWS account ID"
}

variable "domain" {
  type        = string
  description = "Domain"
}

variable "ecr_repo" {
  type        = string
  description = "ECR Repository URL"
}