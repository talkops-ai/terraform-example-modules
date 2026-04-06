variable "name" {
  type        = string
  description = "Name of the VPC"
}

variable "cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "azs" {
  type        = list(string)
  description = "Availability zones"
}

variable "public_subnets" {
  type        = list(string)
  description = "Public subnets CIDR blocks"
}

variable "app_subnets" {
  type        = list(string)
  description = "App subnets CIDR blocks"
}

variable "data_subnets" {
  type        = list(string)
  description = "Data subnets CIDR blocks"
}

variable "management_subnets" {
  type        = list(string)
  description = "Management subnets CIDR blocks"
}

variable "manage_default_security_group" {
  type        = bool
  default     = true
  description = "Whether to manage the default security group"
}