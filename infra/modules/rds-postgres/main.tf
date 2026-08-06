resource "aws_db_subnet_group" "this" {
  name = "${var.name}-postgres"

  description = "Private database subnets used by the PostgreSQL RDS instance."

  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name    = "${var.name}-postgres"
    Service = "postgres"
    Tier    = "data"
  })
}

resource "aws_db_instance" "this" {
  identifier = "${var.name}-postgres"

  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage = var.allocated_storage
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = var.database_name
  username = var.master_username
  port     = 5432

  manage_master_user_password = true

  db_subnet_group_name = aws_db_subnet_group.this.name

  vpc_security_group_ids = [
    var.security_group_id
  ]

  publicly_accessible = false
  multi_az            = var.multi_az

  backup_retention_period = var.backup_retention_days
  backup_window           = "02:00-03:00"
  maintenance_window      = "sun:03:00-sun:04:00"

  auto_minor_version_upgrade  = true
  allow_major_version_upgrade = false
  apply_immediately           = var.apply_immediately

  performance_insights_enabled = false
  monitoring_interval          = 0

  deletion_protection = var.deletion_protection

  skip_final_snapshot = var.skip_final_snapshot

  final_snapshot_identifier = (
    var.skip_final_snapshot
    ? null
    : "${var.name}-postgres-final"
  )

  delete_automated_backups = true
  copy_tags_to_snapshot    = true

  tags = merge(var.tags, {
    Name    = "${var.name}-postgres"
    Service = "postgres"
    Tier    = "data"
  })
}
