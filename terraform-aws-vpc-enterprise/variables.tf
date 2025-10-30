# Terraform Variables
# Generated on 2025-10-30 17:06:31

# Compute Variables

variable "instance_tenancy" {
  type        = string
  description = "Instance tenancy for the VPC. One of: default, dedicated, host."
  default     = "default"

  validation {
    condition     = contains(["default", "dedicated", "host"], value)
    error_message = "instance_tenancy must be one of: default, dedicated, host."
  }
}


variable "application" {
  # Value will be provided via .tfvars
  type        = string
  description = "Application name (alphanumeric, max 32 chars)"

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]{1,32}$", value))
    error_message = "application must be 1-32 characters and contain only letters, numbers, hyphens or underscores."
  }
}


variable "environment" {
  # Value will be provided via .tfvars
  type        = string
  description = "Deployment environment (alphanumeric, max 32 chars)"

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]{1,32}$", value))
    error_message = "environment must be 1-32 characters and contain only letters, numbers, hyphens or underscores."
  }
}


variable "tags" {
  # Value will be provided via .tfvars
  type        = map(string)
  description = "Map of tags to apply to resources. Keys <=128 chars; values <=256 chars."

  validation {
    condition     = length(keys(value)) > 0 && alltrue([for k, v in value : length(k) <= 128 && length(v) <= 256])
    error_message = "tags must contain at least one key and each key must be <=128 chars and each value <=256 chars."
  }
}


# Monitoring Variables

variable "enable_flow_logs" {
  type        = bool
  description = "Enable VPC Flow Logs."
  default     = true
}


variable "flow_logs_destination_type" {
  type        = string
  description = "Destination type for flow logs: cloudwatch, s3, kinesis."
  default     = "cloudwatch"

  validation {
    condition     = contains(["cloudwatch", "s3", "kinesis"], value)
    error_message = "flow_logs_destination_type must be one of: cloudwatch, s3, kinesis."
  }
}


variable "flow_logs_log_group_name" {
  # Value will be provided via .tfvars
  type        = string
  description = "CloudWatch Log Group name for flow logs when using cloudwatch destination."

  validation {
    condition     = length(value) > 0
    error_message = "flow_logs_log_group_name must be provided when using cloudwatch as the flow_logs_destination_type."
  }
}


variable "monitoring_role_arn" {
  # Value will be provided via .tfvars
  type        = string
  description = "IAM Role ARN used by flow logs to publish logs."

  validation {
    condition     = length(value) > 0
    error_message = "monitoring_role_arn must be a non-empty ARN for the flow logs IAM role."
  }
}


# Networking Variables

variable "assign_generated_ipv6_cidr_block" {
  type        = bool
  description = "Assign an AWS-generated IPv6 CIDR block to the VPC."
  default     = false
}


variable "availability_zones" {
  # Value will be provided via .tfvars
  type        = list(string)
  description = "List of availability zone names to create subnets in."

  validation {
    condition     = alltrue([for az in value : length(az) > 0])
    error_message = "Each availability zone entry must be a non-empty string."
  }
}


variable "create_internet_gateway" {
  type        = bool
  description = "Create and attach an Internet Gateway to the VPC."
  default     = true
}


variable "enable_dns_hostnames" {
  type        = bool
  description = "Enable DNS hostnames for the VPC."
  default     = true

  validation {
    condition     = var.enable_dns_support == true ? true : true
    error_message = "If enable_dns_support is disabled, enable_dns_hostnames will have no effect."
  }
}


variable "enable_dns_support" {
  type        = bool
  description = "Enable DNS support for the VPC."
  default     = true
}


variable "enable_vpc_endpoints" {
  type        = bool
  description = "Enable creation of common VPC endpoints."
  default     = true
}


variable "ipv6_ipam_pool_id" {
  # Value will be provided via .tfvars
  type        = string
  description = "IPv6 IPAM pool ID used to allocate IPv6 CIDR ranges."

  validation {
    condition     = length(value) > 0
    error_message = "ipv6_ipam_pool_id must be provided and non-empty when IPv6 allocation is required."
  }
}


variable "management_subnet_cidrs" {
  type        = list(string)
  description = "Optional CIDR blocks for management subnets. If provided must match availability_zones length."
  nullable    = true

  validation {
    condition     = value == null || (length(value) == length(var.availability_zones) && alltrue([for c in value : can(cidrhost(c, 0))]))
    error_message = "management_subnet_cidrs must be null or have the same number of entries as availability_zones and each entry must be a valid CIDR."
  }
}


variable "nat_gateway_strategy" {
  type        = string
  description = "NAT gateway strategy: per_az or centralized."
  default     = "per_az"

  validation {
    condition     = contains(["per_az", "centralized"], value)
    error_message = "nat_gateway_strategy must be one of: per_az, centralized."
  }
}


variable "private_subnet_cidrs" {
  # Value will be provided via .tfvars
  type        = list(string)
  description = "CIDR blocks for private subnets. Must match availability_zones length."

  validation {
    condition     = length(value) == length(var.availability_zones) && alltrue([for c in value : can(cidrhost(c, 0))])
    error_message = "private_subnet_cidrs must have the same number of entries as availability_zones and each entry must be a valid CIDR."
  }
}


variable "private_subnet_map_public_ip_on_launch" {
  type        = bool
  description = "Whether private subnets should map public IPs on launch."
  default     = false
}


variable "public_subnet_cidrs" {
  # Value will be provided via .tfvars
  type        = list(string)
  description = "CIDR blocks for public subnets. Must match availability_zones length."

  validation {
    condition     = length(value) == length(var.availability_zones) && alltrue([for c in value : can(cidrhost(c, 0))])
    error_message = "public_subnet_cidrs must have the same number of entries as availability_zones and each entry must be a valid CIDR."
  }
}


variable "public_subnet_map_public_ip_on_launch" {
  type        = bool
  description = "Whether public subnets should map public IPs on launch."
  default     = true
}


variable "vpc_cidr" {
  # Value will be provided via .tfvars
  type        = string
  description = "Primary VPC CIDR block (must be a valid CIDR, e.g. /16)"

  validation {
    condition     = can(cidrhost(value, 0))
    error_message = "vpc_cidr must be a valid CIDR block (e.g. 10.0.0.0/16)."
  }
}


# Security Variables

variable "kms_key_arn" {
  # Value will be provided via .tfvars
  type        = string
  description = "KMS Key ARN used to encrypt flow logs and other resources."

  validation {
    condition     = length(value) > 0
    error_message = "kms_key_arn must be provided and non-empty when KMS encryption is required."
  }
}
