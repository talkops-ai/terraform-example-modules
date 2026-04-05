locals {
  # Merged map of mandatory and additional tags.
  default_tags = merge(
    {
      CostCenter  = var.cost_center
      Owner       = var.owner
      Project     = var.project
      Environment = var.environment
    },
    var.additional_tags
  )
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.default_tags
  }
}
