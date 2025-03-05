resource "aws_elasticache_replication_group" "redis_cluster" {
  description = "Redis cluster"
  replication_group_id          = "${var.prefix}-redis-cluster"
  engine                        = "redis"
  engine_version                = "7.0"
  node_type                     = var.redis_node_type
  port                          = var.redis_port
  parameter_group_name          = "default.redis7.cluster.on"

  subnet_group_name  = aws_elasticache_subnet_group.cache_subnet.name
  security_group_ids = [ aws_security_group.redis_sg.id ]

  automatic_failover_enabled = true
  multi_az_enabled           = true

  at_rest_encryption_enabled   = true
  transit_encryption_enabled   = true

  snapshot_retention_limit = 7

  num_node_groups         = 3
  replicas_per_node_group = 2

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.redis_slow_log.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "slow-log"
  }
  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.redis_engine_log.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "engine-log"
  }
}
