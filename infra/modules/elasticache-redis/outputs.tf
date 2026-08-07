output "replication_group_id" {
  description = "ElastiCache Redis replication group identifier."
  value       = aws_elasticache_replication_group.this.replication_group_id
}

output "arn" {
  description = "ARN of the ElastiCache Redis replication group."
  value       = aws_elasticache_replication_group.this.arn
}

output "primary_endpoint_address" {
  description = "DNS hostname of the Redis primary endpoint."
  value       = aws_elasticache_replication_group.this.primary_endpoint_address
}

output "port" {
  description = "Redis TCP port."
  value       = aws_elasticache_replication_group.this.port
}

output "engine_version" {
  description = "Configured Redis OSS engine version."
  value       = aws_elasticache_replication_group.this.engine_version
}

output "node_type" {
  description = "ElastiCache Redis node type."
  value       = aws_elasticache_replication_group.this.node_type
}

output "subnet_group_name" {
  description = "Name of the ElastiCache subnet group."
  value       = aws_elasticache_subnet_group.this.name
}
