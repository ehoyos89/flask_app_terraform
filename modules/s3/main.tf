resource "aws_s3_bucket" "photos_bucket" {
  bucket = "${replace(var.project_name, "_", "-")}-${var.environment}-photos"

  tags = {
    Name        = "${var.project_name}-${var.environment}-photos-bucket"
    Environment = var.environment
    Project     = var.project_name
  }
  
}

# Block public access to the bucket
resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.photos_bucket.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# Random ID for the bucket
resource "random_id" "bucket_suffix" {
  byte_length = 6
}