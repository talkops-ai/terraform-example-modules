resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true
  tags = merge(local.common_tags, { Name = "${var.name}-public-${var.azs[count.index]}-res" })
}

resource "aws_subnet" "app" {
  count             = length(var.app_subnets)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.app_subnets[count.index]
  availability_zone = var.azs[count.index]
  tags = merge(local.common_tags, { Name = "${var.name}-app-${var.azs[count.index]}-res" })
}

resource "aws_subnet" "data" {
  count             = length(var.data_subnets)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.data_subnets[count.index]
  availability_zone = var.azs[count.index]
  tags = merge(local.common_tags, { Name = "${var.name}-data-${var.azs[count.index]}-res" })
}

resource "aws_subnet" "management" {
  count             = length(var.management_subnets)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.management_subnets[count.index]
  availability_zone = var.azs[count.index]
  tags = merge(local.common_tags, { Name = "${var.name}-management-${var.azs[count.index]}-res" })
}