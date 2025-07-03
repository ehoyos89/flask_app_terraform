# Random password for the RDS instance
resource "random_password" "db_password" {
  length  = 16
  special = false
}

# Store database password in AWS Secrets Manager
resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "${var.project_name}-${var.environment}-db-credentials"
}

resource "aws_secretsmanager_secret_version" "db_credentials_version" {
  secret_id     = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.db_username,
    password = random_password.db_password.result
  })
}

# Generate a random password for the flask application
resource "random_password" "flask_app_password" {
  length  = 16
  special = false
  upper   = true
  lower   = true
}

resource "aws_secretsmanager_secret" "flask_secret_key" {
  name        = "${var.project_name}-${var.environment}-flask-secret-key"
  description = "Secret key for Flask application ${var.project_name}-${var.environment}"
  
}
resource "aws_secretsmanager_secret_version" "flask_secret_key_version" {
  secret_id     = aws_secretsmanager_secret.flask_secret_key.id
  secret_string = jsonencode({
    secret_key = random_password.flask_app_password.result
  })

}


# DB subnet group for RDS
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-${var.environment}-db-subnet-group"
  }
}

# RDS instance creation
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

# Read replica for production environment
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