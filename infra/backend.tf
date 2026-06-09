# tfstate locking
terraform {
  required_version = ">= 1.1.9"
  backend "s3" {
    bucket         = "memos-tfstate-${var.account_id}"
    key            = "infra/terraform.tfstate"
    region         = var.region
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}

# Allows being able to take outputs from bootstrap as variables in infra
data "terraform_remote_state" "bootstrap_outputs" {
  backend = "s3"
  config = {
    bucket = "memos-tfstate-${var.account_id}"
    key    = "bootstrap/terraform.tfstate"
    region = var.region
  }
}