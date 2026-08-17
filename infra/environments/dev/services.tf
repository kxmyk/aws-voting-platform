locals {
  ecs_service_configuration = {
    vote = {
      security_group_id     = module.security.vote_security_group_id
      load_balancer_enabled = true
      target_group_arn      = module.alb.target_group_arns["vote"]
      container_name        = "vote"
      container_port        = 80
    }

    result = {
      security_group_id     = module.security.result_security_group_id
      load_balancer_enabled = true
      target_group_arn      = module.alb.target_group_arns["result"]
      container_name        = "result"
      container_port        = 80
    }

    worker = {
      security_group_id     = module.security.worker_security_group_id
      load_balancer_enabled = false
      target_group_arn      = null
      container_name        = null
      container_port        = null
    }
  }
}

module "ecs_service" {
  for_each = local.ecs_service_configuration

  source = "../../modules/ecs-service"

  name       = "${var.project_name}-${var.environment}-${each.key}"
  cluster_id = module.ecs.cluster_id

  task_definition_arn = (
    data.aws_ecs_task_definition.active_service[each.key].arn
  )

  desired_count = var.ecs_service_desired_counts[each.key]

  subnet_ids = toset(
    values(module.network.private_app_subnet_ids)
  )

  security_group_ids = toset([
    each.value.security_group_id
  ])

  assign_public_ip = false

  load_balancer_enabled = each.value.load_balancer_enabled
  target_group_arn      = each.value.target_group_arn
  container_name        = each.value.container_name
  container_port        = each.value.container_port

  health_check_grace_period_seconds = var.ecs_service_health_check_grace_period_seconds
  wait_for_steady_state             = var.ecs_service_wait_for_steady_state

  tags = merge(local.common_tags, {
    Service = each.key
  })

  depends_on = [module.alb]
}
