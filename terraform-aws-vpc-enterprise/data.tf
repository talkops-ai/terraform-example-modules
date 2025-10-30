# Data Sources
# This file contains all data source lookups for the infrastructure

# Aws Caller Identity Data Sources
data "aws_caller_identity" "current_caller_identity" {
}


# Aws Region Data Sources
data "aws_region" "aws_region" {
}


# Aws Kms Key Data Sources
data "aws_kms_key" "kms_key" {
  key_id = var.kms_key_arn
}


# Aws Iam Role Data Sources
data "aws_iam_role" "flow_logs_role" {
  arn = var.monitoring_role_arn
}