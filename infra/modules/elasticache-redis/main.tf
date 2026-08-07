resource "aws_elasticache_subnet_group" "this" {
  name = "${var.name}-redis"

  description = "Private data subnets used by ElastiCache Redis."

  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name    = "${var.name}-redis"
    Service = "redis"
    Tier    = "data"
  })
}

resource "aws_elasticache_replication_group" "this" {
  replication_group_id = "${var.name}-redis"

  description = "Redis vote queue for ${var.name}."

  engine         = "redis"
  engine_version = var.engine_version
  node_type      = var.node_type

  port = var.port

  num_cache_clusters = 1

  automatic_failover_enabled = false
  multi_az_enabled            = false

  subnet_group_name = aws_elasticache_subnet_group.this.name

  security_group_ids = [
    var.security_group_id
  ]

  network_type = "ipv4"

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  snapshot_retention_limit = var.snapshot_retention_limit

  auto_minor_version_upgrade = true
  apply_immediately           = var.apply_immediately

  maintenance_window = "sun:04:00-sun:05:00"

  tags = merge(var.tags, {
    Name    = "${var.name}-redis"
    Service = "redis"
    Tier    = "data"
  })
}
