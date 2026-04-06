variable "name" {
  type        = string
  description = "Name tag for all resources"
}

variable "create_s3_bucket" {
  type        = bool
  default     = true
  description = "Controls if S3 bucket should be created"
}

variable "create_s3_bucket_versioning" {
  type        = bool
  default     = true
  description = "Controls if S3 bucket versioning should be created"
}

variable "create_s3_bucket_server_side_encryption_configuration" {
  type        = bool
  default     = true
  description = "Controls if SSE configuration should be created"
}

variable "create_s3_bucket_public_access_block" {
  type        = bool
  default     = true
  description = "Controls if public access block should be created"
}

variable "create_s3_bucket_policy" {
  type        = bool
  default     = true
  description = "Controls if bucket policy should be created"
}

variable "create_s3_bucket_cors_configuration" {
  type        = bool
  default     = true
  description = "Controls if CORS configuration should be created"
}

variable "create_s3_bucket_lifecycle_configuration" {
  type        = bool
  default     = true
  description = "Controls if lifecycle configuration should be created"
}

variable "create_s3_bucket_website_configuration" {
  type        = bool
  default     = true
  description = "Controls if website configuration should be created"
}

variable "create_s3_bucket_replication_configuration" {
  type        = bool
  default     = true
  description = "Controls if replication configuration should be created"
}

variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket suffix. Must be globally unique."
  validation {
    condition     = length(var.bucket_name) > 2 && length(var.bucket_name) < 64
    error_message = "Bucket name must be between 3 and 63 characters."
  }
  validation {
    condition     = can(regex("^[a-z0-9.-]+$", var.bucket_name))
    error_message = "Bucket name must contain only lowercase letters, numbers, periods, and hyphens."
  }
}

variable "environment" {
  type        = string
  default     = "production"
  description = "Deployment environment (e.g., production, staging)."
  validation {
    condition     = contains(["production", "staging", "development"], var.environment)
    error_message = "Environment must be one of: production, staging, development."
  }
}

variable "kms_key_arn" {
  type        = string
  description = "The ARN of the KMS key used for Server-Side Encryption (SSE-KMS)."
  validation {
    condition     = var.kms_key_arn == "" || can(regex("^arn:aws:kms:", var.kms_key_arn))
    error_message = "Must be a valid KMS key ARN."
  }
}

variable "enable_replication" {
  type        = bool
  default     = true
  description = "Enable Cross-Account Same-Region Replication (SRR)."
}

variable "replication_role_arn" {
  type        = string
  default     = ""
  description = "ARN of the IAM role for Amazon S3 to assume when replicating objects."
}

variable "replication_destination_bucket_arn" {
  type        = string
  default     = ""
  description = "ARN of the destination bucket for replication."
}

variable "cloudfront_oac_arn" {
  type        = string
  default     = ""
  description = "ARN of the CloudFront Origin Access Control (OAC) allowed to access the bucket."
}

variable "noncurrent_version_expiration_days" {
  type        = number
  default     = 30
  description = "Number of days before non-current versions are permanently deleted."
  validation {
    condition     = var.noncurrent_version_expiration_days > 0
    error_message = "Expiration days must be greater than 0."
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to all resources"
}

variable "s3_bucket_tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied specifically to the S3 bucket"
}

variable "s3_bucket_versioning_tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied specifically to S3 versioning configuration"
}

variable "s3_bucket_server_side_encryption_configuration_tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied specifically to S3 SSE configuration"
}

variable "s3_bucket_replication_configuration_tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied specifically to S3 replication configuration"
}

variable "s3_bucket_website_configuration_tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied specifically to S3 website configuration"
}

variable "s3_bucket_public_access_block_tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied specifically to S3 public access block"
}

variable "s3_bucket_policy_tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied specifically to S3 bucket policy"
}

variable "s3_bucket_cors_configuration_tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied specifically to S3 CORS configuration"
}

variable "s3_bucket_lifecycle_configuration_tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied specifically to S3 lifecycle configuration"
}
