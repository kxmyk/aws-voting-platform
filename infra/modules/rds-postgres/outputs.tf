output "instance_identifier" {
  description = "User-defined RDS PostgreSQL DB instance identifier."
  value       = aws_db_instance.this.identifier
}

output "resource_id" {
  description = "Internal AWS RDS DBI resource ID."
  value       = aws_db_instance.this.resource_id
}

output "instance_arn" {
  description = "ARN of the RDS PostgreSQL DB instance."
  value       = aws_db_instance.this.arn
}

output "address" {
  description = "DNS address of the PostgreSQL DB instance."
  value       = aws_db_instance.this.address
}

output "port" {
  description = "Port exposed by the PostgreSQL DB instance."
  value       = aws_db_instance.this.port
}

output "endpoint" {
  description = "PostgreSQL endpoint including the port."
  value       = aws_db_instance.this.endpoint
}

output "database_name" {
  description = "Initial PostgreSQL database name."
  value       = aws_db_instance.this.db_name
}

output "master_username" {
  description = "PostgreSQL master username."
  value       = aws_db_instance.this.username
}

output "engine_version" {
  description = "Actual PostgreSQL engine version."
  value       = aws_db_instance.this.engine_version_actual
}

output "db_subnet_group_name" {
  description = "Name of the RDS DB subnet group."
  value       = aws_db_subnet_group.this.name
}

output "master_user_secret_arn" {
  description = "ARN of the RDS-managed Secrets Manager secret."

  value = try(
    aws_db_instance.this.master_user_secret[0].secret_arn,
    null
  )
}
