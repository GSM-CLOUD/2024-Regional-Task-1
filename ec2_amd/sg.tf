resource "aws_security_group" "ec2-amd-sg" {
  vpc_id = var.vpc_id
  description = "ec2-amd-sg"
  ingress = [{
    description = "ec2-amd-sg"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 22
    to_port = 22
    protocol = "tcp"
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
  }]

  egress = [{
    description = "ec2-amd-sg"
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
    "Name" = "${var.prefix}-ec2-amd-sg"
  }
}