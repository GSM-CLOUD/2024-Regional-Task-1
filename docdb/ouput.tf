output "docdb_cluster_endpoint" {
  value = aws_docdb_cluster.mongodb_cluster.endpoint
}

output "docdb_cluster_port" {
  value = aws_docdb_cluster.mongodb_cluster.port
}