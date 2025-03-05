output "redis_cluster_endpoint" {
  value = aws_elasticache_replication_group.redis_cluster.configuration_endpoint_address
}

output "redis_cluster_port" {
  value = aws_elasticache_replication_group.redis_cluster.port
}