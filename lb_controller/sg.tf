resource "aws_security_group" "nlb_sg" {
  vpc_id = var.vpc_id
  description = "nlb-sg"

  ingress = [{
    description = "nlb-sg"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 80
    to_port = 80
    protocol = "tcp"
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
    },{
    description = "nlb-sg"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 443
    to_port = 443
    protocol = "tcp"
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
  }]

  egress = [{
    description = "nlb-sg"
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
    "Name" = "${var.prefix}-nlb-sg"
  }
}