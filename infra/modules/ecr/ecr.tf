# ECR Repository

resource "aws_ecr_repository" "memos_repo" {
  name                 = "memos"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.tags
}



