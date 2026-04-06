output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = try(aws_eks_cluster.this[0].name, null)
}

output "cluster_endpoint" {
  description = "Endpoint of the EKS cluster"
  value       = try(aws_eks_cluster.this[0].endpoint, null)
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = try(aws_security_group.cluster.id, null)
}

output "node_security_group_id" {
  description = "Security group ID attached to the EKS nodes"
  value       = try(aws_security_group.node.id, null)
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if enable_irsa = true"
  value       = try(aws_iam_openid_connect_provider.eks[0].arn, null)
  sensitive   = true
}

output "oidc_provider_url" {
  description = "The URL of the OIDC Provider"
  value       = try(aws_eks_cluster.this[0].identity[0].oidc[0].issuer, null)
}

output "kms_key_arn" {
  description = "The ARN of the KMS key created for cluster encryption"
  value       = var.kms_key_enabled ? try(aws_kms_key.eks[0].arn, null) : var.kms_key_arn
  sensitive   = true
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = try(aws_eks_cluster.this[0].certificate_authority[0].data, null)
}