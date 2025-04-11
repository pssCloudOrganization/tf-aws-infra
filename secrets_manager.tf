resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "*$?[].~,#_%"
}

resource "aws_secretsmanager_secret" "db_password" {
  name                    = "db-password-secret"
  kms_key_id              = aws_kms_key.secrets_key.arn
  recovery_window_in_days = 0
  depends_on              = [aws_kms_key.secrets_key]
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.db_password.result
}


  