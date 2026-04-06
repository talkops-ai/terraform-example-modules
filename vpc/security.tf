resource "aws_default_security_group" "this" {
  count  = var.manage_default_security_group ? 1 : 0
  vpc_id = aws_vpc.this.id
  ingress {}
  egress {}
  tags = merge(local.common_tags, { Name = "${var.name}-default-sg" })
}