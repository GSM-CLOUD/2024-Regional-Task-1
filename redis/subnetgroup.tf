resource "aws_elasticache_subnet_group" "cache_subnet" {
  name = "skills-cache-subnet-group"
  subnet_ids = var.protected_subnets
}