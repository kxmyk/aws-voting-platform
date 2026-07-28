output "alb_security_group_id" {
  description = "Security group ID assigned to the Application Load Balancer."
  value       = aws_security_group.alb.id
}

output "vote_security_group_id" {
  description = "Security group ID assigned to the vote application."
  value       = aws_security_group.vote.id
}

output "result_security_group_id" {
  description = "Security group ID assigned to the result application."
  value       = aws_security_group.result.id
}

output "worker_security_group_id" {
  description = "Security group ID assigned to the worker."
  value       = aws_security_group.worker.id
}

output "redis_security_group_id" {
  description = "Security group ID assigned to Redis."
  value       = aws_security_group.redis.id
}

output "postgres_security_group_id" {
  description = "Security group ID assigned to PostgreSQL."
  value       = aws_security_group.postgres.id
}

output "security_group_ids" {
  description = "Map of all security group IDs created by the module."

  value = {
    alb      = aws_security_group.alb.id
    vote     = aws_security_group.vote.id
    result   = aws_security_group.result.id
    worker   = aws_security_group.worker.id
    redis    = aws_security_group.redis.id
    postgres = aws_security_group.postgres.id
  }
}
