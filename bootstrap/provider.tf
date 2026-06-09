terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.44.0"
    }
  }
}

provider "aws" {
  region = var.region
}

terraform {
  required_version = ">= 1.1.9"
  backend "s3" {
    bucket         = "memos-tfstate-${var.account_id}"
    key            = "bootstrap/terraform.tfstate"
    region         = var.region
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}