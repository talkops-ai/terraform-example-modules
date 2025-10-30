# terraform-aws-vpc-enterprise

## Overview

This Terraform module creates a production-grade AWS VPC tailored for enterprise environments. The module provisions a highly-available VPC with multi-AZ public, private, and optional management subnets; configurable NAT gateway strategy (per-AZ or centralized); Internet Gateway management; per-AZ route tables and associations; VPC Flow Logs with optional KMS encryption and IAM role support; and consistent tagging and naming conventions for operational clarity.

This README is generated from the actual module implementation and inputs/outputs as of generation ID a7de1dcd-418f-4ab4-b3dd-819f87a20d61.

## Features

- Multi-AZ public and private subnets (management subnets optional)
- NAT gateway strategy: per-AZ or centralized
- Internet Gateway creation and attachment (optional)
- Per-AZ route tables and associations
- VPC Flow Logs support (CloudWatch / S3 / Kinesis) with IAM role and KMS integration
- Predictable naming and tagging via computed tags
- Input validation for CIDRs, AZ counts and basic naming constraints
- Exposes outputs for downstream modules and automation

## Requirements

- Terraform: >= 1.3
- Providers:
  - aws (source: hashicorp/aws, version: ~> 4.0)

Example required_providers block for root module:

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

## Quick summary of what is created

- aws_vpc.this
- aws_subnet.public (one per AZ)
- aws_subnet.private (one per AZ)
- aws_subnet.management (optional, one per AZ when management_subnet_cidrs provided)
- aws_internet_gateway.this (optional)
- aws_eip.nat (one per NAT, per availability_zones when per_az)
- aws_nat_gateway.this (per AZ or centralized)
- aws_route_table.public (per AZ)
- aws_route_table.private (per AZ)
- aws_route_table_association.* (for public and private subnets)
- aws_flow_log.this (optional)
- Data lookups: aws_caller_identity, aws_region, aws_kms_key, aws_iam_role

## Inputs (variables)

The module exposes the following input variables (names, types, defaults and brief notes). Use a .tfvars file or set variables in your root module.

- instance_tenancy (string, default: "default")
  - Instance tenancy for the VPC. One of: default, dedicated, host.
  - Validation: must be one of [default, dedicated, host].

- application (string, required)
  - Application name (alphanumeric, max 32 chars). Validation enforces pattern ^[a-zA-Z0-9_-]{1,32}$.

- environment (string, required)
  - Deployment environment (alphanumeric, max 32 chars). Validation enforces pattern ^[a-zA-Z0-9_-]{1,32}$.

- tags (map(string), required)
  - Map of tags to apply to resources. Must contain at least one key. Keys <=128 chars and values <=256 chars.

- enable_flow_logs (bool, default: true)
  - Enable VPC Flow Logs.

- flow_logs_destination_type (string, default: "cloudwatch")
  - Destination type for flow logs: cloudwatch, s3, kinesis.
  - Validation: must be one of [cloudwatch, s3, kinesis].

- flow_logs_log_group_name (string, required when using cloudwatch)
  - CloudWatch Log Group name for flow logs when using cloudwatch destination.

- monitoring_role_arn (string, required when flow logs enabled)
  - IAM Role ARN used by flow logs to publish logs.

- assign_generated_ipv6_cidr_block (bool, default: false)
  - Whether to assign an AWS-generated IPv6 CIDR block to the VPC.

- availability_zones (list(string), required)
  - List of AZ names to create resources in. Each entry must be non-empty.

- create_internet_gateway (bool, default: true)
  - Create and attach an Internet Gateway to the VPC.

- enable_dns_hostnames (bool, default: true)
  - Enable DNS hostnames for the VPC. (Has no effect if enable_dns_support=false.)

- enable_dns_support (bool, default: true)
  - Enable DNS support for the VPC.

- enable_vpc_endpoints (bool, default: true)
  - Enable creation of common VPC endpoints (if implemented/extended downstream).

- ipv6_ipam_pool_id (string, optional)
  - IPv6 IPAM pool ID used to allocate IPv6 CIDR ranges (required if IPv6 allocation is used).

- management_subnet_cidrs (list(string), nullable, default: null)
  - Optional CIDR blocks for management subnets. If provided, must have same length as availability_zones.

- nat_gateway_strategy (string, default: "per_az")
  - NAT gateway strategy: per_az or centralized. Validation ensures either value.

- private_subnet_cidrs (list(string), required)
  - CIDR blocks for private subnets. Must match availability_zones length.

- private_subnet_map_public_ip_on_launch (bool, default: false)
  - Whether private subnets should assign public IPs on launch (default false).

- public_subnet_cidrs (list(string), required)
  - CIDR blocks for public subnets. Must match availability_zones length.

- public_subnet_map_public_ip_on_launch (bool, default: true)
  - Whether public subnets should map public IPs on launch.

- vpc_cidr (string, required)
  - Primary VPC CIDR block (must be a valid CIDR, e.g. 10.0.0.0/16).

- kms_key_arn (string, required)
  - KMS Key ARN used to encrypt flow logs and other resources. Validation enforces non-empty when required.

Notes on input validation:
- The module validates that lists for public_subnet_cidrs, private_subnet_cidrs and availability_zones have matching lengths. management_subnet_cidrs is optional but if provided must match length.
- flow_logs_log_group_name and monitoring_role_arn are expected when flow logs use CloudWatch and when flow logs are enabled.

## Outputs

- tags_all
  - value: aws_vpc.this.tags_all
  - description: All tags associated with the created VPC (computed tags merged with inputs).

- vpc_cidr_block
  - value: aws_vpc.this.cidr_block
  - description: The primary CIDR block of the VPC.

- internet_gateway_id
  - value: aws_internet_gateway.this.id
  - description: The ID of the Internet Gateway attached to the VPC (if created).

- nat_gateway_ids
  - value: local.nat_gateway_id_map
  - description: Map of NAT gateway IDs by AZ (or a centralized key) as constructed in locals.

- vpc_id
  - value: aws_vpc.this.id
  - description: The ID of the VPC.

- vpc_arn
  - value: aws_vpc.this.arn
  - description: The ARN of the VPC.

- flow_log_id
  - value: aws_flow_log.this.id
  - description: The Flow Log ID for the VPC (if flow logs are enabled).

- private_route_table_ids
  - value: values(aws_route_table.private)[*].id
  - description: List of private route table IDs associated with private subnets.

- private_subnet_ids
  - value: values(aws_subnet.private)[*].id
  - description: List of private subnet IDs created in the VPC.

- public_route_table_ids
  - value: values(aws_route_table.public)[*].id
  - description: List of public route table IDs associated with public subnets.

- public_subnet_ids
  - value: values(aws_subnet.public)[*].id
  - description: List of public subnet IDs created in the VPC.

## Data sources used

- data.aws_caller_identity.current_caller_identity: used for identity context where needed.
- data.aws_region.aws_region: used for region lookups.
- data.aws_kms_key.kms_key: looks up the provided kms_key_arn for KMS key metadata and key_id.
- data.aws_iam_role.flow_logs_role: looks up the provided monitoring_role_arn for flow logs IAM role.

## Local values and important computed logic

- local.nat_gateway_count
  - Computed: if nat_gateway_strategy == "per_az" then length(availability_zones) else 1.
  - Used to reason about NAT resource counts and cost.

- local.nat_gateway_id_map
  - If per_az: map of AZ => aws_nat_gateway.this[az].id
  - If centralized: { centralized = aws_nat_gateway.this[0].id }
  - Exposed through output nat_gateway_ids.

- local.route_table_names
  - Names used for public and private route tables: "${application}-${environment}-rt-public" and "${application}-${environment}-rt-private".

- local.validate_az_subnet_lengths
  - Boolean ensuring length checks for AZs and subnet lists; used for early validation.

## Resource behavior and dependency notes

- aws_vpc.this is created first; all subnets depend on it.
- Public and private subnets are created per availability zone using for_each over availability_zones.
- NAT Gateways and Elastic IPs are created per availability zone when nat_gateway_strategy == "per_az"; otherwise a single NAT is created and assigned to the first public subnet (index 0) in the provider's ordering.
- Route tables are created per AZ and private routes reference the per-AZ NAT gateway by AZ key when using per_az. When centralized, private route tables all reference the centralized NAT gateway id from the nat_gateway_id_map.
- Internet gateway creation is conditional on create_internet_gateway and its routes and route table entries reference aws_internet_gateway.this[0].id.
- Flow logs are created conditionally based on enable_flow_logs; the resource references data.aws_iam_role.flow_logs_role and data.aws_kms_key.kms_key for role and KMS information.

## Usage Examples

1) Per-AZ NAT Gateway Deployment (high availability)

module "vpc" {
  source = "./modules/terraform-aws-vpc-enterprise"

  environment = "prod"
  application = "myapp"
  vpc_cidr = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  nat_gateway_strategy = "per_az"
  create_internet_gateway = true
  enable_flow_logs = true
  flow_logs_destination_type = "cloudwatch"
  flow_logs_log_group_name = "/aws/vpc/flow-logs/myapp-prod"
  monitoring_role_arn = "arn:aws:iam::123456789012:role/FlowLogsRole"
  kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/abcd-ef01-2345"
  tags = {
    Environment = "prod"
    Application = "myapp"
    CostCenter = "12345"
    Owner = "team@example.com"
    ManagedBy = "Terraform"
    Module = "vpc"
    CreatedDate = "2023-10-01"
  }
}

Expected outputs: vpc_id, public_subnet_ids, private_subnet_ids, nat_gateway_ids

Use case: High availability production environments requiring fault-isolated NAT gateways.

2) Centralized NAT Gateway Deployment (cost optimized)

module "vpc" {
  source = "./modules/terraform-aws-vpc-enterprise"

  environment = "prod"
  application = "myapp"
  vpc_cidr = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  nat_gateway_strategy = "centralized"
  create_internet_gateway = true
  enable_flow_logs = true
  flow_logs_destination_type = "cloudwatch"
  flow_logs_log_group_name = "/aws/vpc/flow-logs/myapp-prod"
  monitoring_role_arn = "arn:aws:iam::123456789012:role/FlowLogsRole"
  kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/abcd-ef01-2345"
  tags = {
    Environment = "prod"
    Application = "myapp"
    CostCenter = "12345"
    Owner = "team@example.com"
    ManagedBy = "Terraform"
    Module = "vpc"
    CreatedDate = "2023-10-01"
  }
}

Expected outputs: vpc_id, public_subnet_ids, private_subnet_ids, nat_gateway_ids

Use case: Cost-sensitive production environments where cross-AZ NAT traffic is acceptable.

## Security Considerations

- VPC Flow Logs are enabled by default. When using CloudWatch you must supply flow_logs_log_group_name and monitoring_role_arn. The module uses data.aws_kms_key to reference a provided KMS key for encryption ensure the key policy allows the flow logs role to use the key for encryption operations.
- Private subnets default to not mapping public IPs (private_subnet_map_public_ip_on_launch = false).
- The flow logs IAM role must have least-privilege permissions to write to the configured destination.
- Tagging is enforced: provide organizational tags to ensure compliance and cost allocation.
- Ensure monitoring_role_arn and kms_key_arn are provided from secure, audited accounts and rotated according to policy.

## Cost Implications / Optimization

- NAT Gateways are billed hourly + data processing. Using nat_gateway_strategy = "per_az" increases availability but multiplies NAT gateway charges by number of AZs. Use centralized NAT to reduce the number of NAT gateways at the cost of cross-AZ egress traffic.
- Elastic IPs (one per NAT gateway) incur hourly costs when associated.
- VPC Flow Logs to CloudWatch incur CloudWatch Logs ingestion and storage charges; to S3 or Kinesis costs will apply differently choose destination according to long-term cost strategy.
- KMS usage for Flow Logs adds per-API request pricing; consider using a dedicated KMS key with appropriate key policy.
- Use VPC endpoints (when enabled/implemented) to reduce egress through NAT for AWS service traffic saves NAT bandwidth costs.

Recommendations:
- For non-latency-sensitive or cost-sensitive workloads, use centralized NAT.
- Consider consolidation of log destinations or lifecycle policies to control CloudWatch Logs costs.

## Troubleshooting

- Mismatched AZ and subnet list lengths
  - Error: validation will fail if public_subnet_cidrs/private_subnet_cidrs lengths do not match availability_zones. Fix by providing matching lists.

- Flow logs failing to create
  - Verify monitoring_role_arn exists and the role trust policy allows the flow logs service principal.
  - For CloudWatch destination, ensure flow_logs_log_group_name exists and role has logs:PutLogEvents/CreateLogStream permissions; ensure KMS key policy grants encrypt/decrypt to the role if kms_key_arn used.

- NAT gateway route not found / unreachable internet
  - If create_internet_gateway=false, public subnets will not have internet egress. Set create_internet_gateway=true if public egress needed.
  - For centralized NAT ensure the NAT is created in a public subnet with a route table referencing the centralized NAT id.

- IAM / KMS permission errors
  - Confirm data.aws_kms_key.kms_key resolves a key_id and that the role used by flow logs has kms:Encrypt/kms:GenerateDataKey on the key.

Debugging tips:
- Use terraform plan and inspect local.nat_gateway_id_map and local.nat_gateway_count to confirm expected NAT placements.
- Inspect aws_flow_log.this in AWS console for status and last error.

## Implementation Guidance

- State management: use a remote backend (S3 + DynamoDB lock) and separate state per environment / team.
- CI/CD: include terraform validate, plan, and apply with approval stages. Provide required variables via secure variable store or CI secrets.
- Naming: The module uses "${application}-${environment}-*" naming for certain resources to keep clarity across environments.

## Contact

For support, contact the platform team: platform@example.com
