output "karpenter_controller_role_arn" {
  description = "ARN of the IAM role for the Karpenter controller"
  value       = try(aws_iam_role.karpenter_controller[0].arn, null)
}

output "karpenter_controller_role_name" {
  description = "Name of the IAM role for the Karpenter controller"
  value       = try(aws_iam_role.karpenter_controller[0].name, null)
}

output "karpenter_node_role_arn" {
  description = "ARN of the IAM role for Karpenter provisioned EC2 nodes"
  value       = aws_iam_role.karpenter_node.arn
}

output "karpenter_node_instance_profile_name" {
  description = "Name of the IAM instance profile for Karpenter provisioned EC2 nodes"
  value       = aws_iam_instance_profile.karpenter_node.name
}

output "karpenter_interruption_queue_name" {
  description = "Name of the SQS queue for Karpenter interruption handling"
  value       = try(aws_sqs_queue.karpenter_interruption[0].name, null)
}

output "karpenter_interruption_queue_arn" {
  description = "ARN of the SQS queue for Karpenter interruption handling"
  value       = try(aws_sqs_queue.karpenter_interruption[0].arn, null)
}