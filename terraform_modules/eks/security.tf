resource "aws_security_group" "cluster" {
  name        = "eks-cluster-sg-${local.cluster_name}"
  description = "EKS cluster security group"
  vpc_id      = var.vpc_id

  tags = merge(
    { "Name" = "eks-cluster-sg-${local.cluster_name}" },
    local.common_tags
  )
}

resource "aws_vpc_security_group_ingress_rule" "cluster_ingress" {
  security_group_id            = aws_security_group.cluster.id
  description                  = "Node groups to cluster API"
  referenced_security_group_id = aws_security_group.node.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "cluster_egress" {
  security_group_id = aws_security_group.cluster.id
  description       = "Cluster to internet/nodes"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_security_group" "node" {
  name        = "eks-node-sg-${local.cluster_name}"
  description = "EKS node security group"
  vpc_id      = var.vpc_id

  tags = merge(
    {
      "Name"                                        = "eks-node-sg-${local.cluster_name}"
      "kubernetes.io/cluster/${local.cluster_name}" = "owned"
    },
    local.common_tags
  )
}

resource "aws_vpc_security_group_ingress_rule" "node_ingress_self" {
  security_group_id            = aws_security_group.node.id
  description                  = "Node to node all ports/protocols"
  referenced_security_group_id = aws_security_group.node.id
  ip_protocol                  = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "node_ingress_cluster" {
  security_group_id            = aws_security_group.node.id
  description                  = "Cluster to nodes 443"
  referenced_security_group_id = aws_security_group.cluster.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "node_ingress_cluster_kubelet" {
  security_group_id            = aws_security_group.node.id
  description                  = "Cluster to nodes 10250 (kubelet)"
  referenced_security_group_id = aws_security_group.cluster.id
  from_port                    = 10250
  to_port                      = 10250
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "node_ingress_cluster_coredns" {
  security_group_id            = aws_security_group.node.id
  description                  = "Cluster to nodes 53 (CoreDNS)"
  referenced_security_group_id = aws_security_group.cluster.id
  from_port                    = 53
  to_port                      = 53
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "node_ingress_cluster_coredns_udp" {
  security_group_id            = aws_security_group.node.id
  description                  = "Cluster to nodes 53 (CoreDNS UDP)"
  referenced_security_group_id = aws_security_group.cluster.id
  from_port                    = 53
  to_port                      = 53
  ip_protocol                  = "udp"
}

resource "aws_vpc_security_group_egress_rule" "node_egress" {
  security_group_id = aws_security_group.node.id
  description       = "Node to internet/all"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}