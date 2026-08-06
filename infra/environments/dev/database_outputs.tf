output "postgres_instance_identifier" {
  description = "User-defined RDS PostgreSQL DB instance identifier."
  value       = module.postgres.instance_identifier
}

output "postgres_resource_id" {
  description = "Internal AWS RDS DBI resource ID."
  value       = module.postgres.resource_id
}

output "postgres_instance_arn" {
  description = "ARN of the RDS PostgreSQL DB instance."
  value       = module.postgres.instance_arn
}

output "postgres_address" {
  description = "Private DNS address of the PostgreSQL DB instance."
  value       = module.postgres.address
}

output "postgres_port" {
  description = "PostgreSQL port."
  value       = module.postgres.port
}

output "postgres_endpoint" {
  description = "PostgreSQL endpoint including the port."
  value       = module.postgres.endpoint
}

output "postgres_database_name" {
  description = "Initial PostgreSQL database name."
  value       = module.postgres.database_name
}

output "postgres_master_username" {
  description = "PostgreSQL master username."
  value       = module.postgres.master_username
}

output "postgres_engine_version" {
  description = "Actual PostgreSQL engine version."
  value       = module.postgres.engine_version
}

output "postgres_db_subnet_group_name" {
  description = "Name of the RDS DB subnet group."
  value       = module.postgres.db_subnet_group_name
}

output "postgres_master_user_secret_arn" {
  description = "ARN of the RDS-managed master-user secret."
  value       = module.postgres.master_user_secret_arn
}
