# Usage: Standard output required for referencing the bucket in other modules.
output "bucket_id" {
  description = "The name of the bucket."
  value       = try(aws_s3_bucket.this[0].id, null)
  depends_on  = [aws_s3_bucket.this]
}

# Usage: Required for cross-module IAM role and policy attachments.
output "bucket_arn" {
  description = "The ARN of the bucket."
  value       = try(aws_s3_bucket.this[0].arn, null)
  depends_on  = [aws_s3_bucket.this]
}

# Usage: Crucial for configuring CloudFront distributions with OAC.
output "bucket_regional_domain_name" {
  description = "The bucket region-specific domain name."
  value       = try(aws_s3_bucket.this[0].bucket_regional_domain_name, null)
  depends_on  = [aws_s3_bucket.this]
}
