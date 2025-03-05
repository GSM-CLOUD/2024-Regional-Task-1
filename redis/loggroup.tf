resource "aws_cloudwatch_log_group" "redis_slow_log" {
    name = "redis/slow-log"
    retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "redis_engine_log" {
  name = "redis/engine-log"
  retention_in_days = 7
}