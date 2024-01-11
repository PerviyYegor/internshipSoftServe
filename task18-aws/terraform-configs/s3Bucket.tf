resource "aws_s3_bucket" "health_check_bucket" {
  bucket = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.health_check_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}