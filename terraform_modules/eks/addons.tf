locals {
  addons = {
    vpc-cni = {
      addon_name = "vpc-cni"
    }
    coredns = {
      addon_name = "coredns"
    }
    kube-proxy = {
      addon_name = "kube-proxy"
    }
    eks-pod-identity-agent = {
      addon_name = "eks-pod-identity-agent"
    }
  }
}

resource "aws_eks_addon" "addons" {
  for_each = var.create_eks ? local.addons : {}

  cluster_name = aws_eks_cluster.this[0].name
  addon_name   = each.value.addon_name

  resolve_conflicts_on_update = "PRESERVE"
  resolve_conflicts_on_create = "OVERWRITE"

  tags = merge(
    { "Name" = "addon-${each.value.addon_name}-${local.cluster_name}" },
    local.common_tags
  )

  depends_on = [
    aws_eks_node_group.system
  ]
}