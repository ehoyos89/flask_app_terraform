# Contraseña aleatoria para la instancia RDS.
# Genera una contraseña segura para la base de datos.
resource "random_password" "db_password" {
  length  = 16
  special = false
}

# Almacena la contraseña de la base de datos en AWS Secrets Manager.
# Guarda las credenciales de la base de datos de forma segura.
resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "${var.project_name}-${var.environment}-db-credentials"
}

# Versión del secreto de las credenciales de la base de datos.
# Almacena el nombre de usuario y la contraseña en el secreto.
resource "aws_secretsmanager_secret_version" "db_credentials_version" {
  secret_id     = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.db_username,
    password = random_password.db_password.result
  })
}

# Genera una contraseña aleatoria para la aplicación Flask.
# Crea una clave secreta para la aplicación Flask.
resource "random_password" "flask_app_password" {
  length  = 16
  special = false
  upper   = true
  lower   = true
}

# Almacena la clave secreta de Flask en AWS Secrets Manager.
resource "aws_secretsmanager_secret" "flask_secret_key" {
  name        = "${var.project_name}-${var.environment}-flask-secret-key"
  description = "Secret key for Flask application ${var.project_name}-${var.environment}"
  
}
# Versión del secreto de la clave de Flask.
# Almacena la clave secreta en el secreto.
resource "aws_secretsmanager_secret_version" "flask_secret_key_version" {
  secret_id     = aws_secretsmanager_secret.flask_secret_key.id
  secret_string = jsonencode({
    secret_key = random_password.flask_app_password.result
  })

}


# Grupo de subredes de base de datos para RDS.
# Define las subredes en las que se desplegará la instancia RDS.
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-${var.environment}-db-subnet-group"
  }
}

# Creación de la instancia RDS.
# Crea la instancia de la base de datos MySQL.
resource "aws_db_instance" "main" {
  identifier = "${replace(var.project_name, "_", "-")}-${var.environment}-db"

  engine = "mysql"
  engine_version = "8.0.41"
  instance_class = var.db_instance_class
  allocated_storage = var.db_allocated_storage
  max_allocated_storage = var.db_allocated_storage * 2
  storage_type = "gp3"
  storage_encrypted = true  
  username = jsondecode(aws_secretsmanager_secret_version.db_credentials_version.secret_string)["username"]
  password = jsondecode(aws_secretsmanager_secret_version.db_credentials_version.secret_string)["password"]
  db_name = var.db_name
  vpc_security_group_ids = [var.security_group_id]
  db_subnet_group_name = aws_db_subnet_group.main.name

  multi_az = var.multi_az
  backup_retention_period = var.multi_az ? 7 : 1
  deletion_protection = false
  skip_final_snapshot = true

  performance_insights_enabled = false

  tags = {
    Name = "${var.project_name}-${var.environment}-db"
  }
  
}

# Réplica de lectura para el entorno de producción.
# Crea una réplica de lectura para mejorar la disponibilidad y el rendimiento.
resource "aws_db_instance" "replica" {
  count = var.multi_az ? 1 : 0

  identifier = "${replace(var.project_name, "_", "-")}-${var.environment}-db-replica"

  replicate_source_db = aws_db_instance.main.identifier
  instance_class = var.db_instance_class

  publicly_accessible = false

  tags = {
    Name = "${var.project_name}-${var.environment}-db-replica"
  }
}