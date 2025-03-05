resource "aws_secretsmanager_secret" "secrets_store" {
  name = "${var.prefix}-secretsmanager-store"

  tags = {
    Name = "${var.prefix}-secretsmanager-store"
  }
}

resource "aws_secretsmanager_secret_version" "secrets_store_version" {
  secret_id     = aws_secretsmanager_secret.secrets_store.id
  secret_string = jsonencode({
    "secretValue" = "secret"
  })
}