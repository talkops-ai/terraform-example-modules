data "aws_region" "current" {}

locals {
  bucket_name = "s3-bucket-${var.environment}-${data.aws_region.current.id}-${var.bucket_name}"
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = lookup(var.tags, "Project", "Required")
      CostCenter  = lookup(var.tags, "CostCenter", "Required")
    }
  )
}

resource "aws_s3_bucket" "this" {
  count         = var.create_s3_bucket ? 1 : 0
  bucket        = local.bucket_name
  force_destroy = false

  tags = merge(
    { "Name" = var.name },
    local.common_tags,
    var.s3_bucket_tags,
  )

  lifecycle {
    prevent_destroy = true
  }
}
