resource "aws_cloudwatch_log_group" "eks" {
  count             = var.create_eks ? 1 : 0
  name              = "/aws/eks/${local.cluster_name}/cluster"
  retention_in_days = 90
  kms_key_id        = var.kms_key_enabled ? aws_kms_key.eks[0].arn : var.kms_key_arn

  tags = merge(
    { "Name" = "cw-logs-${local.cluster_name}" },
    local.common_tags
  )
}