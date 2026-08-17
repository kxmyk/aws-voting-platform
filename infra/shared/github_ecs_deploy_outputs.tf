output "github_actions_ecs_deploy_role_name" {
  description = "Name of the IAM role used by GitHub Actions for ECS deployments."
  value       = aws_iam_role.github_actions_ecs_deploy.name
}

output "github_actions_ecs_deploy_role_arn" {
  description = "ARN of the IAM role used by GitHub Actions for ECS deployments."
  value       = aws_iam_role.github_actions_ecs_deploy.arn
}

output "github_actions_ecs_deploy_policy_arn" {
  description = "ARN of the least-privilege ECS deployment policy."
  value       = aws_iam_policy.github_actions_ecs_deploy.arn
}

output "github_actions_ecs_deploy_service_arns" {
  description = "ECS service ARNs that GitHub Actions is allowed to deploy."
  value       = local.github_ecs_deployment_service_arns
}

output "github_actions_ecs_deploy_task_definition_arns" {
  description = "ECS task definition ARN patterns that GitHub Actions is allowed to register."
  value       = local.github_ecs_deployment_task_definition_arns
}
