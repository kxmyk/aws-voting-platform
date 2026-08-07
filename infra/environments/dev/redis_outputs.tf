output "redis_replication_group_id" {
  description = "ElastiCache Redis replication group identifier."
  value       = module.redis.replication_group_id
}

output "redis_arn" {
  description = "ARN of the ElastiCache Redis replication group."
  value       = module.redis.arn
}

output "redis_address" {
  description = "Private DNS hostname of the Redis primary endpoint."
  value       = module.redis.primary_endpoint_address
}

output "redis_port" {
  description = "Redis TCP port."
  value       = module.redis.port
}

output "redis_engine_version" {
  description = "Redis OSS engine version."
  value       = module.redis.engine_version
}

output "redis_node_type" {
  description = "ElastiCache Redis node type."
  value       = module.redis.node_type
}

output "redis_subnet_group_name" {
  description = "Name of the ElastiCache subnet group."
  value       = module.redis.subnet_group_name
}
