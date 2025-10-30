# Terraform Resources
# Generated on 2025-10-30 17:02:01

resource "aws_vpc" "this" {
  cidr_block                         = var.vpc_cidr
  instance_tenancy                   = var.instance_tenancy
  enable_dns_support                 = var.enable_dns_support
  enable_dns_hostnames               = var.enable_dns_hostnames
  assign_generated_ipv6_cidr_block   = var.assign_generated_ipv6_cidr_block
  ipv6_ipam_pool_id                  = var.ipv6_ipam_pool_id
  ipv6_cidr_block_network_border_group = var.ipv6_cidr_block_network_border_group
  tags                               = local.computed_tags
}


resource "aws_subnet" "public" {
  for_each                        = local.az_subnet_index_map
  vpc_id                          = aws_vpc.this.id
  cidr_block                      = var.public_subnet_cidrs[each.value]
  availability_zone               = each.key
  availability_zone_id            = null
  map_public_ip_on_launch         = var.public_subnet_map_public_ip_on_launch
  assign_ipv6_address_on_creation = var.assign_generated_ipv6_cidr_block
  ipv6_cidr_block                 = null
  outpost_arn                     = null
  tags                            = merge(local.computed_tags, { Name = local.subnet_names[each.key].public })
  depends_on = [aws_vpc.this]
}


resource "aws_subnet" "private" {
  for_each                        = local.az_subnet_index_map
  vpc_id                          = aws_vpc.this.id
  cidr_block                      = var.private_subnet_cidrs[each.value]
  availability_zone               = each.key
  availability_zone_id            = null
  map_public_ip_on_launch         = var.private_subnet_map_public_ip_on_launch
  assign_ipv6_address_on_creation = var.assign_generated_ipv6_cidr_block
  ipv6_cidr_block                 = null
  outpost_arn                     = null
  tags                            = merge(local.computed_tags, { Name = local.subnet_names[each.key].private })
  depends_on = [aws_vpc.this]
}


resource "aws_subnet" "management" {
  for_each                        = local.az_subnet_index_map
  vpc_id                          = aws_vpc.this.id
  cidr_block                      = var.management_subnet_cidrs != null ? var.management_subnet_cidrs[each.value] : ""
  availability_zone               = each.key
  availability_zone_id            = null
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = var.assign_generated_ipv6_cidr_block
  ipv6_cidr_block                 = null
  outpost_arn                     = null
  tags                            = merge(local.computed_tags, { Name = local.subnet_names[each.key].management })
  depends_on = [aws_vpc.this]
}


resource "aws_internet_gateway" "this" {
  count  = var.create_internet_gateway ? 1 : 0
  vpc_id = aws_vpc.this.id
  tags   = local.computed_tags
  depends_on = [aws_vpc.this]
}


resource "aws_eip" "nat" {
  for_each = toset(var.availability_zones)
  vpc      = true
  tags     = local.computed_tags
  depends_on = [aws_vpc.this]
}


resource "aws_nat_gateway" "this" {
  for_each     = toset(var.availability_zones)
  subnet_id    = aws_subnet.public[each.key].id
  allocation_id = aws_eip.nat[each.key].id
  private_ip   = null
  connectivity_type = null
  tags         = merge(local.computed_tags, { Name = "${var.application}-${var.environment}-nat-${each.key}" })
  depends_on = [aws_subnet.public, aws_eip.nat]
}


resource "aws_route_table" "public" {
  for_each = toset(var.availability_zones)
  vpc_id   = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this[0].id
  }

  tags = merge(local.computed_tags, { Name = local.route_table_names.public })
  depends_on = [aws_internet_gateway.this]
}


resource "aws_route_table" "private" {
  for_each = toset(var.availability_zones)
  vpc_id   = aws_vpc.this.id

  route {
    cidr_block    = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[each.key].id
  }

  tags = merge(local.computed_tags, { Name = "${local.route_table_names.private}-${each.key}" })
  depends_on = [aws_nat_gateway.this]
}


resource "aws_route_table_association" "public" {
  for_each      = aws_subnet.public
  route_table_id = aws_route_table.public[each.key].id
  subnet_id      = each.value.id
  gateway_id     = aws_internet_gateway.this[0].id
  depends_on = [aws_route_table.public, aws_subnet.public]
}


resource "aws_route_table_association" "private" {
  for_each      = aws_subnet.private
  route_table_id = aws_route_table.private[each.key].id
  subnet_id      = each.value.id
  gateway_id     = null
  depends_on = [aws_route_table.private, aws_subnet.private]
}


resource "aws_flow_log" "this" {
  count                = var.enable_flow_logs ? 1 : 0
  log_destination_type = var.flow_logs_destination_type
  log_group_name       = var.flow_logs_log_group_name
  resource_id          = aws_vpc.this.id
  traffic_type         = "ALL"
  log_destination      = var.flow_logs_destination_type == "cloudwatch" ? var.flow_logs_log_group_name : ""
  iam_role_arn         = data.aws_iam_role.flow_logs_role.arn
  tags                 = local.computed_tags
  kms_key_id           = data.aws_kms_key.kms_key.key_id
  depends_on = [aws_vpc.this]
}
