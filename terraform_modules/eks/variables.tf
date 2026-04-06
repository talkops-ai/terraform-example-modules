variable "create_eks" {
  description = "Controls if EKS resources should be created (it affects almost all resources)"
  type        = bool
  default     = true
}

variable "name" {
  description = "Name tag for all resources"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster. If not provided, it will use eks-environment-name."
  type        = string
  default     = ""

  validation {
    condition     = var.cluster_name == "" || (length(var.cluster_name) > 0 && length(var.cluster_name) <= 100)
    error_message = "Cluster name must be between 1 and 100 characters."
  }
}

variable "environment" {
  description = "Environment identifier for the EKS cluster (e.g., production)"
  type        = string
  default     = "production"
}

variable "vpc_id" {
  description = "ID of the VPC where the EKS cluster will be deployed"
  type        = string

  validation {
    condition     = can(regex("^vpc-", var.vpc_id))
    error_message = "VPC ID must start with 'vpc-'."
  }
}

variable "vpc_subnet_ids" {
  description = "The IDs of the subnets in the VPC that can be used by EKS"
  type        = list(string)

  validation {
    condition     = length(var.vpc_subnet_ids) >= 2
    error_message = "At least two subnet IDs are required for high availability."
  }
}

variable "cluster_endpoint_private_access" {
  description = "Whether the Amazon EKS private API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "Whether the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = false
}

variable "kms_key_enabled" {
  description = "Controls if a KMS key for cluster encryption should be created"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "ARN of an existing KMS key to use if kms_key_enabled is false"
  type        = string
  default     = null
  sensitive   = true
}

variable "cluster_log_types" {
  description = "A list of desired control plane logs to enable for the EKS cluster"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "system_node_group_instance_types" {
  description = "List of instance types associated with the system EKS Node Group"
  type        = list(string)
  default     = ["c7g.large", "m7g.large"]
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default     = {}
}