resource "aws_s3_bucket_website_configuration" "this" {
  count  = var.create_s3_bucket && var.create_s3_bucket_website_configuration && var.cloudfront_oac_arn == "" ? 1 : 0
  bucket = aws_s3_bucket.this[0].id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  depends_on = [aws_s3_bucket.this]
}

resource "aws_s3_bucket_cors_configuration" "this" {
  count  = var.create_s3_bucket && var.create_s3_bucket_cors_configuration ? 1 : 0
  bucket = aws_s3_bucket.this[0].id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 300
  }

  depends_on = [aws_s3_bucket.this]
}
