output "ecs_task_definition_arns" {
  description = "ECS task definition ARNs indexed by application service."

  value = {
    for service_name, task_definition
    in aws_ecs_task_definition.service :
    service_name => task_definition.arn
  }
}

output "ecs_task_definition_families" {
  description = "ECS task definition families indexed by application service."

  value = {
    for service_name, task_definition
    in aws_ecs_task_definition.service :
    service_name => task_definition.family
  }
}

output "ecs_task_definition_revisions" {
  description = "ECS task definition revisions indexed by application service."

  value = {
    for service_name, task_definition
    in aws_ecs_task_definition.service :
    service_name => task_definition.revision
  }
}

output "ecs_bootstrap_image_uris" {
  description = "Immutable ECR image URIs used by the initial ECS task definitions."

  value = {
    for service_name, image
    in data.aws_ecr_image.service :
    service_name => image.image_uri
  }
}
