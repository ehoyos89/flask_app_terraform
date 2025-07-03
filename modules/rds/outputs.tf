output "db_endpoint" {
  description = "The endpoint of the RDS database"
  value       = aws_db_instance.main.endpoint
}

output "db_password_secret_arn" {
  description = "The ARN of the Secrets Manager secret containing the database password"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "db_username_secret_arn" {
  description = "The ARN of the Secrets Manager secret containing the database username"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "flask_secret_key_secret_arn" {
  description = "The ARN of the Secrets Manager secret containing the Flask secret key"
  value       = aws_secretsmanager_secret.flask_secret_key.arn
}

output "db_replica_endpoint" {
  description = "The endpoint of the RDS read replica"
  value       = var.multi_az ? aws_db_instance.replica[0].endpoint : null
}

