# Salida para el nombre del bucket de S3.
# Descripción: El nombre del bucket de S3 para las fotos.
output "photos_bucket_name" {
  description = "The name of the S3 bucket for photos."
  value       = module.s3.photos_bucket_name
}