resource "aws_s3_bucket_versioning" "this" {
  count  = var.create_s3_bucket && var.create_s3_bucket_versioning ? 1 : 0
  bucket = aws_s3_bucket.this[0].id

  versioning_configuration {
    status = "Enabled"
  }

  depends_on = [aws_s3_bucket.this]
}

resource "aws_s3_bucket_replication_configuration" "this" {
  count  = var.create_s3_bucket && var.enable_replication && var.create_s3_bucket_replication_configuration ? 1 : 0
  bucket = aws_s3_bucket.this[0].id
  role   = var.replication_role_arn

  rule {
    id     = "srr-replication"
    status = "Enabled"

    destination {
      bucket = var.replication_destination_bucket_arn
    }
  }

  depends_on = [
    aws_s3_bucket_versioning.this
  ]
}
