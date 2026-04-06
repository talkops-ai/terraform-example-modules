resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count  = var.create_s3_bucket && var.create_s3_bucket_server_side_encryption_configuration ? 1 : 0
  bucket = aws_s3_bucket.this[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
    bucket_key_enabled = true
  }

  depends_on = [aws_s3_bucket.this]
}

resource "aws_s3_bucket_public_access_block" "this" {
  count  = var.create_s3_bucket && var.create_s3_bucket_public_access_block ? 1 : 0
  bucket = aws_s3_bucket.this[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [aws_s3_bucket.this]
}

data "aws_iam_policy_document" "bucket_policy" {
  count = var.create_s3_bucket && var.create_s3_bucket_policy ? 1 : 0

  statement {
    sid    = "EnforceTLS"
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.this[0].arn,
      "${aws_s3_bucket.this[0].arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  dynamic "statement" {
    for_each = var.cloudfront_oac_arn != "" ? [1] : []
    content {
      sid    = "AllowCloudFrontOAC"
      effect = "Allow"
      principals {
        type        = "Service"
        identifiers = ["cloudfront.amazonaws.com"]
      }
      actions = ["s3:GetObject"]
      resources = [
        "${aws_s3_bucket.this[0].arn}/*"
      ]
      condition {
        test     = "StringEquals"
        variable = "AWS:SourceArn"
        values   = [var.cloudfront_oac_arn]
      }
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  count  = var.create_s3_bucket && var.create_s3_bucket_policy ? 1 : 0
  bucket = aws_s3_bucket.this[0].id
  policy = data.aws_iam_policy_document.bucket_policy[0].json

  depends_on = [aws_s3_bucket_public_access_block.this]
}
