output "photos_bucket_name" {
  description = "The name of the S3 bucket for photos."
  value       = aws_s3_bucket.photos_bucket.bucket
}
