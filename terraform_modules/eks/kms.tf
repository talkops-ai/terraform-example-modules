resource "aws_kms_key" "eks" {
  count                   = var.create_eks && var.kms_key_enabled ? 1 : 0
  description             = "EKS Secret Encryption Key"
  enable_key_rotation     = true
  deletion_window_in_days = 7

  tags = merge(
    { "Name" = "kms-eks-${local.cluster_name}" },
    local.common_tags
  )
}

resource "aws_kms_alias" "eks" {
  count         = var.create_eks && var.kms_key_enabled ? 1 : 0
  name          = "alias/eks-${local.cluster_name}"
  target_key_id = aws_kms_key.eks[0].key_id
}

resource "aws_kms_key" "ebs_sqs" {
  count                   = var.create_eks && var.kms_key_enabled ? 1 : 0
  description             = "KMS Key for EBS and SQS encryption (used by Karpenter and Nodes)"
  enable_key_rotation     = true
  deletion_window_in_days = 7

  tags = merge(
    { "Name" = "kms-ebs-sqs-${local.cluster_name}" },
    local.common_tags
  )
}

resource "aws_kms_alias" "ebs_sqs" {
  count         = var.create_eks && var.kms_key_enabled ? 1 : 0
  name          = "alias/ebs-sqs-${local.cluster_name}"
  target_key_id = aws_kms_key.ebs_sqs[0].key_id
}