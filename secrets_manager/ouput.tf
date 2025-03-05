output "secret_manager_name" {
  value = aws_secretsmanager_secret.secrets_store.name
}

output "secrets_manager_arn" {
  value = aws_secretsmanager_secret.secrets_store.arn
}