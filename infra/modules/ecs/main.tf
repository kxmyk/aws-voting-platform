resource "aws_ecs_cluster" "this" {
  name = "${var.name}-cluster"

  setting {
    name = "containerInsights"

    value = (
      var.container_insights_enabled
      ? "enabled"
      : "disabled"
    )
  }

  tags = merge(var.tags, {
    Name = "${var.name}-cluster"
  })
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = local.capacity_providers

  default_capacity_provider_strategy {
    base              = 1
    weight            = 1
    capacity_provider = "FARGATE"
  }
}

resource "aws_cloudwatch_log_group" "service" {
  for_each = local.service_log_groups

  name              = each.value
  retention_in_days = var.log_retention_days
  log_group_class   = "STANDARD"

  skip_destroy                = false
  deletion_protection_enabled = false

  tags = merge(var.tags, {
    Name    = each.value
    Service = each.key
  })
}
