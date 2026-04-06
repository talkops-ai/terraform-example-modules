# Karpenter Controller Role and Policy via EKS Pod Identity

data "aws_iam_policy_document" "karpenter_controller_assume_role" {
  statement {
    actions = ["sts:AssumeRole", "sts:TagSession"]

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "karpenter_controller" {
  count = var.create_karpenter_iam_role ? 1 : 0

  name                  = local.karpenter_controller_role_name
  description           = "IAM Role for Karpenter Controller (Pod Identity)"
  assume_role_policy    = data.aws_iam_policy_document.karpenter_controller_assume_role.json
  force_detach_policies = true

  tags = merge(
    { "Name" = local.karpenter_controller_role_name },
    local.common_tags
  )
}

data "aws_iam_policy_document" "karpenter_controller" {
  statement {
    sid = "Karpenter"
    actions = [
      "ssm:GetParameter",
      "ec2:DescribeImages",
      "ec2:RunInstances",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeLaunchTemplates",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeInstanceTypeOfferings",
      "ec2:DeleteLaunchTemplate",
      "ec2:CreateTags",
      "ec2:CreateLaunchTemplate",
      "ec2:CreateFleet",
      "ec2:DescribeSpotPriceHistory",
      "pricing:GetProducts"
    ]
    resources = ["*"]
  }

  statement {
    sid = "ConditionalEC2Termination"
    actions = [
      "ec2:TerminateInstances"
    ]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "ec2:ResourceTag/karpenter.sh/nodepool"
      values   = ["*"]
    }
  }

  statement {
    sid       = "PassNodeRole"
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.karpenter_node.arn]
  }

  statement {
    sid       = "EKSClusterEndpointLookup"
    actions   = ["eks:DescribeCluster"]
    resources = ["arn:${data.aws_partition.current.partition}:eks:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster/${var.cluster_name}"]
  }
}

resource "aws_iam_policy" "karpenter_controller" {
  count = var.create_karpenter_iam_role ? 1 : 0

  name_prefix = "KarpenterControllerPolicy-"
  description = "Provides permissions to Karpenter to manage EC2 instances and volumes"
  policy      = data.aws_iam_policy_document.karpenter_controller.json

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "karpenter_controller" {
  count = var.create_karpenter_iam_role ? 1 : 0

  role       = aws_iam_role.karpenter_controller[0].name
  policy_arn = aws_iam_policy.karpenter_controller[0].arn
}

resource "aws_eks_pod_identity_association" "karpenter" {
  count = var.create_karpenter_iam_role ? 1 : 0

  cluster_name    = var.cluster_name
  namespace       = var.k8s_service_account_namespace
  service_account = var.k8s_service_account_name
  role_arn        = aws_iam_role.karpenter_controller[0].arn
}