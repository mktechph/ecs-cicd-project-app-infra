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

resource "aws_ecr_repository" "ecr_repo_api" {
  name                 = "ecr_repo_api"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

#data "aws_ecr_repository" "data_ecr_repo_fe" {
#  name = aws_ecr_repository.ecr_repo_fe.name
#}


#data "aws_ecr_image" "data_ecr_image_fe" {
#  repository_name = aws_ecr_repository.ecr_repo_fe.name
#  most_recent     = true
#}
#
##data "aws_ecr_repository" "data_ecr_repo_oauth" {
##  name = aws_ecr_repository.ecr_repo_oauth.name
##}
#
#
#data "aws_ecr_image" "data_ecr_image_oauth" {
#  repository_name = aws_ecr_repository.ecr_repo_oauth.name
#  most_recent     = true
#}