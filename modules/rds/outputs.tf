# Salida para el endpoint de la base de datos.
# Descripción: El endpoint de la base de datos RDS.
output "db_endpoint" {
  description = "The endpoint of the RDS database"
  value       = aws_db_instance.main.endpoint
}

# Salida para el ARN del secreto de la contraseña de la base de datos.
# Descripción: El ARN del secreto de Secrets Manager que contiene la contraseña de la base de datos.
output "db_password_secret_arn" {
  description = "The ARN of the Secrets Manager secret containing the database password"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

# Salida para el ARN del secreto del nombre de usuario de la base de datos.
# Descripción: El ARN del secreto de Secrets Manager que contiene el nombre de usuario de la base de datos.
output "db_username_secret_arn" {
  description = "The ARN of the Secrets Manager secret containing the database username"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

# Salida para el ARN del secreto de la clave secreta de Flask.
# Descripción: El ARN del secreto de Secrets Manager que contiene la clave secreta de Flask.
output "flask_secret_key_secret_arn" {
  description = "The ARN of the Secrets Manager secret containing the Flask secret key"
  value       = aws_secretsmanager_secret.flask_secret_key.arn
}

# Salida para el endpoint de la réplica de lectura de la base de datos.
# Descripción: El endpoint de la réplica de lectura de RDS.
output "db_replica_endpoint" {
  description = "The endpoint of the RDS read replica"
  value       = var.multi_az ? aws_db_instance.replica[0].endpoint : null
}

