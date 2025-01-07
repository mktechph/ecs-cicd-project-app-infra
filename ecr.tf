resource "aws_ecr_repository" "ecr_repo_fe" {
  name                 = "ecr_repo_fe"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecr_repository" "ecr_repo_oauth" {
  name                 = "ecr_repo_oauth"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}