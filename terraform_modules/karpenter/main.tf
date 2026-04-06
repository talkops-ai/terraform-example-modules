data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  karpenter_controller_role_name = coalesce(var.karpenter_controller_role_name, "KarpenterController-${var.cluster_name}")
  sqs_queue_name                 = "karpenter-${var.cluster_name}"

  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Service     = "Karpenter"
      CostCenter  = "Required"
      ClusterName = var.cluster_name
    }
  )
}