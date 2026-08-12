resource "aws_ecs_service" "this" {
  name = var.name

  cluster         = var.cluster_id
  task_definition = var.task_definition_arn
  desired_count   = var.desired_count

  launch_type      = "FARGATE"
  platform_version = var.platform_version

  scheduling_strategy = "REPLICA"

  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  deployment_controller {
    type = "ECS"
  }

  network_configuration {
    assign_public_ip = var.assign_public_ip
    subnets          = sort(tolist(var.subnet_ids))
    security_groups  = sort(tolist(var.security_group_ids))
  }

  dynamic "load_balancer" {
    for_each = var.load_balancer_enabled ? [1] : []

    content {
      target_group_arn = var.target_group_arn
      container_name   = var.container_name
      container_port   = var.container_port
    }
  }

  health_check_grace_period_seconds = (
    var.load_balancer_enabled
    ? var.health_check_grace_period_seconds
    : null
  )

  enable_ecs_managed_tags = true
  enable_execute_command  = false
  propagate_tags          = "SERVICE"

  wait_for_steady_state = var.wait_for_steady_state

  lifecycle {
    precondition {
      condition = (
        var.load_balancer_enabled
        ? var.target_group_arn != null && var.container_name != null && var.container_port != null
        : var.target_group_arn == null && var.container_name == null && var.container_port == null
      )

      error_message = "target_group_arn, container_name, and container_port must either all be configured or all be null."
    }
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}
