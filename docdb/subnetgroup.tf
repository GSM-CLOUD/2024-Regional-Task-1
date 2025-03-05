resource "aws_docdb_subnet_group" "docdb_subnet_group" {
  name = "${var.prefix}-db-subnet-group"
  subnet_ids = var.protected_subnets
}