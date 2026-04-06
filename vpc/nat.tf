locals {
  nat_gateway_count = length(var.public_subnets)
}

resource "aws_eip" "nat" {
  count  = local.nat_gateway_count
  domain = "vpc"
  tags = merge(local.common_tags, { Name = "${var.name}-eip-${var.azs[count.index]}-res" })
  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  count         = local.nat_gateway_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags = merge(local.common_tags, { Name = "${var.name}-nat-${var.azs[count.index]}-res" })
}