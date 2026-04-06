resource "aws_sqs_queue" "karpenter_interruption_dlq" {
  count = var.enable_spot_interruption_handling ? 1 : 0

  name                      = "${local.sqs_queue_name}-dlq"
  kms_master_key_id         = var.sqs_enable_encryption ? var.sqs_kms_master_key_id : null
  message_retention_seconds = 1209600

  tags = merge(
    { "Name" = "${local.sqs_queue_name}-dlq" },
    local.common_tags
  )
}

resource "aws_sqs_queue" "karpenter_interruption" {
  count = var.enable_spot_interruption_handling ? 1 : 0

  name                      = local.sqs_queue_name
  message_retention_seconds = 300
  kms_master_key_id         = var.sqs_enable_encryption ? var.sqs_kms_master_key_id : null

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.karpenter_interruption_dlq[0].arn
    maxReceiveCount     = 4
  })

  tags = merge(
    { "Name" = local.sqs_queue_name },
    local.common_tags
  )
}

data "aws_iam_policy_document" "karpenter_interruption" {
  count = var.enable_spot_interruption_handling ? 1 : 0

  statement {
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.karpenter_interruption[0].arn]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com", "sqs.amazonaws.com"]
    }
  }

  statement {
    actions = [
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage"
    ]
    resources = [aws_sqs_queue.karpenter_interruption[0].arn]

    principals {
      type        = "AWS"
      identifiers = var.create_karpenter_iam_role ? [aws_iam_role.karpenter_controller[0].arn] : []
    }
  }
}

resource "aws_sqs_queue_policy" "karpenter_interruption" {
  count = var.enable_spot_interruption_handling ? 1 : 0

  queue_url = aws_sqs_queue.karpenter_interruption[0].id
  policy    = data.aws_iam_policy_document.karpenter_interruption[0].json
}