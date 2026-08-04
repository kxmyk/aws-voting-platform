output "cluster_id" {
  description = "ID of the ECS cluster."
  value       = aws_ecs_cluster.this.id
}

output "cluster_name" {
  description = "Name of the ECS cluster."
  value       = aws_ecs_cluster.this.name
}

output "cluster_arn" {
  description = "ARN of the ECS cluster."
  value       = aws_ecs_cluster.this.arn
}

output "capacity_providers" {
  description = "Capacity providers associated with the ECS cluster."
  value       = aws_ecs_cluster_capacity_providers.this.capacity_providers
}

output "log_group_names" {
  description = "CloudWatch Log Group names indexed by application service."

  value = {
    for service_name, log_group in aws_cloudwatch_log_group.service :
    service_name => log_group.name
  }
}

output "log_group_arns" {
  description = "CloudWatch Log Group ARNs indexed by application service."

  value = {
    for service_name, log_group in aws_cloudwatch_log_group.service :
    service_name => log_group.arn
  }
}

output "task_execution_role_name" {
  description = "Name of the IAM role used by ECS when starting tasks."
  value       = aws_iam_role.task_execution.name
}

output "task_execution_role_arn" {
  description = "ARN of the IAM role used by ECS when starting tasks."
  value       = aws_iam_role.task_execution.arn
}

output "task_execution_policy_arn" {
  description = "ARN of the least-privilege ECS task execution policy."
  value       = aws_iam_policy.task_execution.arn
}

output "task_role_names" {
  description = "Application task role names indexed by service."

  value = {
    for service_name, role in aws_iam_role.task :
    service_name => role.name
  }
}

output "task_role_arns" {
  description = "Application task role ARNs indexed by service."

  value = {
    for service_name, role in aws_iam_role.task :
    service_name => role.arn
  }
}
