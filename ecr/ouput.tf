output "ecr_token_uri" {
  value = aws_ecr_repository.token-ecr.repository_url
}

output "ecr_user_uri" {
  value = aws_ecr_repository.user-ecr.repository_url
}