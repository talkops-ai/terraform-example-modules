resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = merge(local.common_tags, { Name = "${var.name}-public-rt" })
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "app" {
  count  = length(var.app_subnets)
  vpc_id = aws_vpc.this.id
  tags = merge(local.common_tags, { Name = "${var.name}-app-rt-${var.azs[count.index]}" })
}

resource "aws_route" "app_nat_gateway" {
  count                  = length(var.app_subnets)
  route_table_id         = aws_route_table.app[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[count.index].id
}

resource "aws_route_table_association" "app" {
  count          = length(var.app_subnets)
  subnet_id      = aws_subnet.app[count.index].id
  route_table_id = aws_route_table.app[count.index].id
}

resource "aws_route_table" "data" {
  count  = length(var.data_subnets)
  vpc_id = aws_vpc.this.id
  tags = merge(local.common_tags, { Name = "${var.name}-data-rt-${var.azs[count.index]}" })
}

resource "aws_route_table_association" "data" {
  count          = length(var.data_subnets)
  subnet_id      = aws_subnet.data[count.index].id
  route_table_id = aws_route_table.data[count.index].id
}

resource "aws_route_table" "management" {
  count  = length(var.management_subnets)
  vpc_id = aws_vpc.this.id
  tags = merge(local.common_tags, { Name = "${var.name}-management-rt-${var.azs[count.index]}" })
}

resource "aws_route_table_association" "management" {
  count          = length(var.management_subnets)
  subnet_id      = aws_subnet.management[count.index].id
  route_table_id = aws_route_table.management[count.index].id
}