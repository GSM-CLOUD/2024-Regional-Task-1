resource "aws_security_group" "bastion-sg" {
  vpc_id = var.vpc_id
  description = "bastion-sg"
  ingress = [{
    description = "bastion-sg"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = var.bastion_port
    to_port = var.bastion_port
    protocol = "tcp"
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
  }]

  egress = [{
    description = "bastion-sg"
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
    "Name" = "${var.prefix}-bastion-sg"
  }
}