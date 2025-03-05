resource "aws_security_group" "redis_sg" {
  name        = "${var.prefix}-redis-sg"
  description = "redis-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.redis_port
    to_port     = var.redis_port
    protocol    = "tcp"
    security_groups =  [var.eks_node_sg_id, var.eks_cluster_sg_id, var.worker_node_security_group_id, var.plane_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "${var.prefix}-redis-sg"
  }
}

resource "aws_security_group_rule" "allow_redis_access_to_eks" {
  type = "ingress"
  from_port = var.redis_port
  to_port = var.redis_port
  protocol = "tcp"
  source_security_group_id = aws_security_group.redis_sg.id
  security_group_id = var.eks_cluster_sg_id
}

resource "aws_security_group_rule" "allow_redis_access_to_node" {
  type = "ingress"
  from_port = var.redis_port
  to_port = var.redis_port
  protocol = "tcp"
  source_security_group_id = aws_security_group.redis_sg.id
  security_group_id = var.eks_node_sg_id
}

resource "aws_security_group_rule" "all_redis_access_to_worker_node" {
  type = "ingress"
  from_port = var.redis_port
  to_port = var.redis_port
  protocol = "tcp"
  source_security_group_id = aws_security_group.redis_sg.id
  security_group_id = var.worker_node_security_group_id
}

resource "aws_security_group_rule" "allow_redis_access_to_plane" {
  type = "ingress"
  from_port = var.redis_port
  to_port = var.redis_port
  protocol = "tcp"
  source_security_group_id = aws_security_group.redis_sg.id
  security_group_id = var.plane_security_group_id
}