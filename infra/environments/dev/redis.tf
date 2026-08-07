module "redis" {
  source = "../../modules/elasticache-redis"

  name = "${var.project_name}-${var.environment}"

  subnet_ids = toset(
    values(module.network.private_data_subnet_ids)
  )

  security_group_id = module.security.redis_security_group_id

  engine_version = var.redis_engine_version
  node_type      = var.redis_node_type

  port = 6379

  snapshot_retention_limit = var.redis_snapshot_retention_limit

  apply_immediately = true

  tags = local.common_tags
}
