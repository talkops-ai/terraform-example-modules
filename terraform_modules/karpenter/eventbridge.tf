locals {
  events = {
    spot_interruption = {
      name        = "SpotInterruption-${var.cluster_name}"
      description = "Karpenter Spot Interruption handling for ${var.cluster_name}"
      event_pattern = jsonencode({
        source      = ["aws.ec2"]
        detail-type = ["EC2 Spot Instance Interruption Warning"]
      })
    }
    rebalance_recommendation = {
      name        = "RebalanceRecommendation-${var.cluster_name}"
      description = "Karpenter Spot Rebalance Recommendation handling for ${var.cluster_name}"
      event_pattern = jsonencode({
        source      = ["aws.ec2"]
        detail-type = ["EC2 Instance Rebalance Recommendation"]
      })
    }
    instance_state_change = {
      name        = "InstanceStateChange-${var.cluster_name}"
      description = "Karpenter Instance State Change handling for ${var.cluster_name}"
      event_pattern = jsonencode({
        source      = ["aws.ec2"]
        detail-type = ["EC2 Instance State-change Notification"]
      })
    }
    health_event = {
      name        = "HealthEvent-${var.cluster_name}"
      description = "Karpenter Health Event handling for ${var.cluster_name}"
      event_pattern = jsonencode({
        source      = ["aws.health"]
        detail-type = ["AWS Health Event"]
      })
    }
  }
}

resource "aws_cloudwatch_event_rule" "spot_interruption" {
  for_each = var.enable_spot_interruption_handling ? local.events : {}

  name          = each.value.name
  description   = each.value.description
  event_pattern = each.value.event_pattern

  tags = merge(
    { "Name" = each.value.name },
    local.common_tags
  )
}

resource "aws_cloudwatch_event_target" "spot_interruption_sqs" {
  for_each = var.enable_spot_interruption_handling ? local.events : {}

  rule      = aws_cloudwatch_event_rule.spot_interruption[each.key].name
  target_id = "KarpenterInterruptionSQS"
  arn       = aws_sqs_queue.karpenter_interruption[0].arn
}