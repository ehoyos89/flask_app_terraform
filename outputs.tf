output "photos_bucket_name" {
  description = "The name of the S3 bucket for photos."
  value       = module.s3.photos_bucket_name
}