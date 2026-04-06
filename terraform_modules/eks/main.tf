locals {
  cluster_name = coalesce(var.cluster_name, "eks-${var.environment}-${var.name}")

  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Service     = "EKS"
      CostCenter  = "Required"
    }
  )
}

data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_eks_cluster" "this" {
  count = var.create_eks ? 1 : 0

  name                      = local.cluster_name
  role_arn                  = aws_iam_role.cluster.arn
  enabled_cluster_log_types = var.cluster_log_types

  vpc_config {
    subnet_ids              = var.vpc_subnet_ids
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
    security_group_ids      = [aws_security_group.cluster.id]
  }

  encryption_config {
    provider {
      key_arn = var.kms_key_enabled ? aws_kms_key.eks[0].arn : var.kms_key_arn
    }
    resources = ["secrets"]
  }

  tags = merge(
    { "Name" = local.cluster_name },
    local.common_tags
  )

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy,
    aws_cloudwatch_log_group.eks
  ]
}