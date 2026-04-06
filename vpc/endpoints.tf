resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.this.id
  service_name = "com.amazonaws.region.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = concat(aws_route_table.app[*].id, aws_route_table.data[*].id)
  tags = merge(local.common_tags, { Name = "${var.name}-s3-endpoint" })
}