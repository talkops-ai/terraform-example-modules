# S3 Terraform Module

This module provides a generic, highly optimized, and secure S3 bucket configuration enforcing TLS, optional CloudFront OAC, SSE-KMS, Intelligent-Tiering, and automated cross-account/same-region replication.

## Key Features
- **S3 Bucket Creation & Encryption**: Enforces SSE-KMS by default.
- **Same-Region & Cross-Account Replication**: Configurable replication leveraging versioning.
- **Static Website Hosting**: Configured for static websites. Automatically disabled when a CloudFront OAC ARN is provided, enforcing secure access through CloudFront.
- **Cost Optimization**: Includes lifecycle configurations mapping to Intelligent-Tiering and cleaning up noncurrent versions/multipart uploads.
- **Security Default**: Uses `aws_s3_bucket_public_access_block` and enforcing TLS requests in the bucket policy.

## Usage

```hcl
module "s3_optimized" {
  source = "./modules/s3"

  name        = "my-production-bucket"
  bucket_name = "website-assets"
  environment = "production"
  kms_key_arn = "arn:aws:kms:ap-south-1:123456789012:key/your-kms-key-id"

  # Replication configuration
  enable_replication                 = true
  replication_role_arn               = "arn:aws:iam::123456789012:role/ReplicationRole"
  replication_destination_bucket_arn = "arn:aws:s3:::destination-bucket-name"

  # CloudFront OAC (If specified, public website config is disabled)
  cloudfront_oac_arn = "arn:aws:cloudfront::123456789012:origin-access-control/E1234567890"

  tags = {
    Project    = "WebApp"
    CostCenter = "IT-123"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.39.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | Name tag for all resources | `string` | n/a | yes |
| `bucket_name` | Name of the S3 bucket suffix. Must be globally unique. | `string` | n/a | yes |
| `environment` | Deployment environment (e.g., production, staging) | `string` | `"production"` | no |
| `kms_key_arn` | The ARN of the KMS key used for Server-Side Encryption (SSE-KMS) | `string` | n/a | yes |
| `enable_replication` | Enable Cross-Account Same-Region Replication (SRR) | `bool` | `true` | no |
| `replication_role_arn` | ARN of the IAM role for Amazon S3 to assume when replicating objects | `string` | `""` | no |
| `replication_destination_bucket_arn` | ARN of the destination bucket for replication | `string` | `""` | no |
| `cloudfront_oac_arn` | ARN of the CloudFront Origin Access Control (OAC) | `string` | `""` | no |
| `noncurrent_version_expiration_days` | Number of days before non-current versions are permanently deleted | `number` | `30` | no |
| `tags` | Tags applied to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `bucket_id` | The name of the bucket |
| `bucket_arn` | The ARN of the bucket |
| `bucket_regional_domain_name` | The bucket region-specific domain name |
