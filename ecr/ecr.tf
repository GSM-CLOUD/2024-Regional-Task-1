resource "aws_ecr_repository" "user-ecr" {
    name = "user"
    image_tag_mutability = "IMMUTABLE"
    force_delete = true
    image_scanning_configuration {
      scan_on_push = true
    }

    tags = {
      "Name" = "user"
    }
}

resource "aws_ecr_repository" "token-ecr" {
    name = "token"
    image_tag_mutability = "IMMUTABLE"

    force_delete = true

    image_scanning_configuration {
      scan_on_push = true
    }

    tags = {
      "Name" = "token"
    }
}