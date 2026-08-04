locals {
  service_log_groups = {
    for service_name in var.service_names :
    service_name => "/ecs/${var.name}/${service_name}"
  }

  capacity_providers = (
    var.enable_fargate_spot
    ? toset([
      "FARGATE",
      "FARGATE_SPOT"
    ])
    : toset([
      "FARGATE"
    ])
  )

  log_stream_arns = [
    for log_group in aws_cloudwatch_log_group.service :
    "${log_group.arn}:*"
  ]
}
