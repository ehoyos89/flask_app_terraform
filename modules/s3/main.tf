# Recurso para el bucket de S3.
# Crea un bucket de S3 para almacenar las fotos de la aplicación.
resource "aws_s3_bucket" "photos_bucket" {
  bucket = "${replace(var.project_name, "_", "-")}-${var.environment}-photos"

  tags = {
    Name        = "${var.project_name}-${var.environment}-photos-bucket"
    Environment = var.environment
    Project     = var.project_name
  }
  
}

# Bloquea el acceso público al bucket.
# Asegura que el contenido del bucket no sea accesible públicamente.
resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.photos_bucket.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# ID aleatorio para el bucket.
# Genera un ID aleatorio para asegurar que el nombre del bucket sea único.
resource "random_id" "bucket_suffix" {
  byte_length = 6
}