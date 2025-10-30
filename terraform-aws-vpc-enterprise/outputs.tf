# Terraform Outputs
# Generated on 2025-10-30 17:10:20

# Configuration_Reference Outputs

output "tags_all" {
  value       = aws_vpc.this.tags_all
  description = "All tags associated with the created VPC (computed tags merged with inputs)"
  depends_on  = [aws_vpc.this]
}


output "vpc_cidr_block" {
  value       = aws_vpc.this.cidr_block
  description = "The primary CIDR block of the VPC"
}


# Connectivity Outputs

output "internet_gateway_id" {
  value       = aws_internet_gateway.this.id
  description = "The ID of the Internet Gateway attached to the VPC (if created)"
  depends_on  = [aws_internet_gateway.this]
}


output "nat_gateway_ids" {
  value       = local.nat_gateway_id_map
  description = "Map of NAT gateway IDs by AZ (or centralized key) as constructed in locals"
  depends_on = [aws_nat_gateway.this]
}


output "vpc_id" {
  value       = aws_vpc.this.id
  description = "The ID of the VPC"
}


# Identity Outputs

output "vpc_arn" {
  value       = aws_vpc.this.arn
  description = "The ARN of the VPC"
}


# Monitoring Outputs

output "flow_log_id" {
  value       = aws_flow_log.this.id
  description = "The Flow Log ID for the VPC (if flow logs are enabled)"
  depends_on  = [aws_flow_log.this]
}


# Networking Outputs

output "private_route_table_ids" {
  value       = values(aws_route_table.private)[*].id
  description = "List of private route table IDs associated with private subnets"
  depends_on  = [aws_route_table.private]
}


output "private_subnet_ids" {
  value       = values(aws_subnet.private)[*].id
  description = "List of private subnet IDs created in the VPC"
  depends_on = [aws_subnet.private]
}


output "public_route_table_ids" {
  value       = values(aws_route_table.public)[*].id
  description = "List of public route table IDs associated with public subnets"
  depends_on = [aws_route_table.public]
}


output "public_subnet_ids" {
  value       = values(aws_subnet.public)[*].id
  description = "List of public subnet IDs created in the VPC"
  depends_on = [aws_subnet.public]
}
