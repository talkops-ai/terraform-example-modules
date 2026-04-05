variable "aws_region" {
  description = "The AWS region to deploy resources into."
  type        = string
  default     = "ap-south-1"
}

variable "cost_center" {
  description = "The cost center identifier for billing and chargebacks."
  type        = string

  validation {
    condition     = length(var.cost_center) > 0
    error_message = "The cost_center variable must not be empty."
  }
}

variable "owner" {
  description = "The team or individual responsible for the resources."
  type        = string

  validation {
    condition     = length(var.owner) > 0
    error_message = "The owner variable must not be empty."
  }
}

variable "project" {
  description = "The project name associated with the resources."
  type        = string

  validation {
    condition     = length(var.project) > 0
    error_message = "The project variable must not be empty."
  }
}

variable "environment" {
  description = "The deployment environment (e.g., dev, staging, prod)."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod", "sandbox"], var.environment)
    error_message = "The environment must be one of: dev, staging, prod, sandbox."
  }
}

variable "additional_tags" {
  description = "Additional custom tags to merge with the mandatory default tags."
  type        = map(string)
  default     = {}
}
