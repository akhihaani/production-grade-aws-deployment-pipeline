locals {
  name   = "memos"
  domain = "memos.abuniyyah.uk"
  region = "eu-west-2"

  tags = {
    Environment = "Production"
    Project     = "Memos Application"
    Owner       = "abu-niyyah"
  }
}