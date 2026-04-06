resource "aws_eks_node_group" "system" {
  count = var.create_eks ? 1 : 0

  cluster_name    = aws_eks_cluster.this[0].name
  node_group_name = "system-nodes"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.vpc_subnet_ids

  ami_type       = "AL2_ARM_64"
  capacity_type  = "ON_DEMAND"
  instance_types = var.system_node_group_instance_types

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 2
  }

  update_config {
    max_unavailable = 1
  }

  tags = merge(
    { "Name" = "system-nodes-${local.cluster_name}" },
    local.common_tags
  )

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  depends_on = [
    aws_eks_cluster.this,
    aws_iam_role_policy_attachment.node_policy
  ]
}