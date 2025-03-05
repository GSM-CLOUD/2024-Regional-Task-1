resource "aws_docdb_cluster" "mongodb_cluster" {
  cluster_identifier = "${var.prefix}-mongodb-cluster"

  engine                  = "docdb"
  engine_version          = "5.0.0"

  master_username         = var.mongodb_username
  master_password         = var.mongodb_password

  storage_encrypted       = true
  kms_key_id              = aws_kms_key.docdb_kms.arn
  vpc_security_group_ids  = [aws_security_group.docdb_sg.id]

  db_subnet_group_name    = aws_docdb_subnet_group.docdb_subnet_group.name
  port                    = var.docdb_port

  backup_retention_period = 7
  skip_final_snapshot     = true

  enabled_cloudwatch_logs_exports = ["audit", "profiler"]

  tags = {
    "Name" = "${var.prefix}-mongodb-cluster"
  }
}

resource "aws_docdb_cluster_instance" "docdb_cluster_instances" {
  count = 2
  identifier = "${var.prefix}-mongodb-cluster-instance-${count.index}"
  cluster_identifier = aws_docdb_cluster.mongodb_cluster.id
  instance_class = var.db_instance_class
}