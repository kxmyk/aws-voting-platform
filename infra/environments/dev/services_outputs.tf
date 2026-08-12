output "ecs_service_ids" {
  description = "ECS service IDs indexed by application service."

  value = {
    for service_name, service in module.ecs_service :
    service_name => service.id
  }
}

output "ecs_service_names" {
  description = "ECS service names indexed by application service."

  value = {
    for service_name, service in module.ecs_service :
    service_name => service.name
  }
}

output "ecs_service_arns" {
  description = "ECS service ARNs indexed by application service."

  value = {
    for service_name, service in module.ecs_service :
    service_name => service.arn
  }
}

output "ecs_service_desired_counts" {
  description = "Desired task counts indexed by application service."

  value = {
    for service_name, service in module.ecs_service :
    service_name => service.desired_count
  }
}
