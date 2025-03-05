resource "aws_security_group" "worker_node_sg" {
    vpc_id = var.vpc_id
  ingress = [{
    description = "worker_node-sg"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 80
    to_port = 80
    protocol = "tcp"
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
    }]

    egress = [{
    description = "worker_node-sg"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 0
    protocol = "-1"
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
    }]

    tags = {
      "Name" = "${var.prefix}-worker-node-sg"
    }
}