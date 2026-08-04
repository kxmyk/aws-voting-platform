output "ecs_cluster_id" {
  description = "ID of the development ECS cluster."
  value       = module.ecs.cluster_id
}

output "ecs_cluster_name" {
  description = "Name of the development ECS cluster."
  value       = module.ecs.cluster_name
}

output "ecs_cluster_arn" {
  description = "ARN of the development ECS cluster."
  value       = module.ecs.cluster_arn
}

output "ecs_capacity_providers" {
  description = "Capacity providers associated with the development ECS cluster."
  value       = module.ecs.capacity_providers
}

output "ecs_log_group_names" {
  description = "CloudWatch Log Group names indexed by application service."
  value       = module.ecs.log_group_names
}

output "ecs_log_group_arns" {
  description = "CloudWatch Log Group ARNs indexed by application service."
  value       = module.ecs.log_group_arns
}

output "ecs_task_execution_role_name" {
  description = "Name of the development ECS task execution role."
  value       = module.ecs.task_execution_role_name
}

output "ecs_task_execution_role_arn" {
  description = "ARN of the development ECS task execution role."
  value       = module.ecs.task_execution_role_arn
}

output "ecs_task_execution_policy_arn" {
  description = "ARN of the development ECS task execution policy."
  value       = module.ecs.task_execution_policy_arn
}

output "ecs_task_role_names" {
  description = "Application ECS task role names indexed by service."
  value       = module.ecs.task_role_names
}

output "ecs_task_role_arns" {
  description = "Application ECS task role ARNs indexed by service."
  value       = module.ecs.task_role_arns
}
