output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "app_subnets" {
  description = "List of IDs of app subnets"
  value       = aws_subnet.app[*].id
}

output "data_subnets" {
  description = "List of IDs of data subnets"
  value       = aws_subnet.data[*].id
}

output "management_subnets" {
  description = "List of IDs of management subnets"
  value       = aws_subnet.management[*].id
}