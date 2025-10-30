# Local Values
# This file contains all computed local values for the infrastructure


locals {
  # Number of NAT gateways to create. Uses per-AZ count when strategy is 'per_az', otherwise a single centralized NAT.
  nat_gateway_count = var.nat_gateway_strategy == "per_az" ? length(var.availability_zones) : 1
  # Map of NAT gateway IDs keyed by AZ when using per-AZ strategy; otherwise a centralized entry.
  nat_gateway_id_map = var.nat_gateway_strategy == "per_az" ? { for az in var.availability_zones : az => aws_nat_gateway.this[az].id } : { centralized = aws_nat_gateway.this[0].id }
  # Consistent names for public and private route tables for tagging and naming.
  route_table_names = { public = "${var.application}-${var.environment}-rt-public", private = "${var.application}-${var.environment}-rt-private" }
  # Boolean validation that ensures subnet CIDR lists align with the number of availability zones (management subnets optional).
  validate_az_subnet_lengths = length(var.availability_zones) == length(var.public_subnet_cidrs) && length(var.availability_zones) == length(var.private_subnet_cidrs) && (var.management_subnet_cidrs == null || length(var.availability_zones) == length(var.management_subnet_cidrs))
}
