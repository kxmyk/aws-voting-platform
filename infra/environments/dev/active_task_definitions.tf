data "aws_ecs_task_definition" "active_service" {
  for_each = var.ecs_service_names

  task_definition = (
    aws_ecs_task_definition.service[each.key].family
  )
}
