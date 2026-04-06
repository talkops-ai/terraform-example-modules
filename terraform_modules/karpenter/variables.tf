variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "Endpoint of the EKS cluster"
  type        = string
}

variable "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider"
  type        = string
}

variable "environment" {
  description = "Environment identifier (e.g., production, development)"
  type        = string
  default     = "production"
}

variable "create_karpenter_iam_role" {
  description = "Controls if the Karpenter IAM role via Pod Identity should be created"
  type        = bool
  default     = true
}

variable "karpenter_controller_role_name" {
  description = "Name of the IAM role for the Karpenter controller. If not provided, it will use KarpenterController-<cluster_name>."
  type        = string
  default     = ""
}

variable "k8s_service_account_namespace" {
  description = "The namespace for the Karpenter service account"
  type        = string
  default     = "kube-system"
}

variable "k8s_service_account_name" {
  description = "The name of the Karpenter service account"
  type        = string
  default     = "karpenter"
}

variable "enable_spot_interruption_handling" {
  description = "Controls if the SQS queue and EventBridge rules for Spot interruptions should be created"
  type        = bool
  default     = true
}

variable "sqs_enable_encryption" {
  description = "Controls if KMS encryption should be enabled on the SQS queue"
  type        = bool
  default     = true
}

variable "sqs_kms_master_key_id" {
  description = "KMS master key ID for SQS queue encryption. If null, uses the default AWS managed key."
  type        = string
  default     = "alias/aws/sqs"
  sensitive   = true
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default     = {}
}