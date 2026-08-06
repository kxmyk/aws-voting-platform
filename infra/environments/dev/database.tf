data "aws_rds_engine_version" "postgres" {
  engine  = "postgres"
  version = var.postgres_engine_major_version
  latest  = true
}

module "postgres" {
  source = "../../modules/rds-postgres"

  name = "${var.project_name}-${var.environment}"

  subnet_ids = toset(
    values(module.network.private_data_subnet_ids)
  )

  security_group_id = module.security.postgres_security_group_id

  engine_version = data.aws_rds_engine_version.postgres.version_actual
  instance_class = var.postgres_instance_class

  allocated_storage = var.postgres_allocated_storage
  database_name     = var.postgres_database_name
  master_username   = var.postgres_master_username

  backup_retention_days = var.postgres_backup_retention_days

  multi_az            = var.postgres_multi_az
  deletion_protection = var.postgres_deletion_protection
  skip_final_snapshot = var.postgres_skip_final_snapshot

  apply_immediately = true

  tags = local.common_tags
}
