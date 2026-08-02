output "aws_account_id" {
  description = "AWS account ID containing the shared infrastructure."
  value       = data.aws_caller_identity.current.account_id
}

output "repository_names" {
  description = "ECR repository names indexed by service."
  value       = module.ecr.repository_names
}

output "repository_urls" {
  description = "ECR repository URLs indexed by service."
  value       = module.ecr.repository_urls
}

output "repository_arns" {
  description = "ECR repository ARNs indexed by service."
  value       = module.ecr.repository_arns
}

output "vote_repository_url" {
  description = "ECR repository URL for the vote service."
  value       = module.ecr.repository_urls["vote"]
}

output "result_repository_url" {
  description = "ECR repository URL for the result service."
  value       = module.ecr.repository_urls["result"]
}

output "worker_repository_url" {
  description = "ECR repository URL for the worker service."
  value       = module.ecr.repository_urls["worker"]
}

output "github_oidc_provider_arn" {
  description = "ARN of the GitHub Actions OIDC identity provider."
  value       = aws_iam_openid_connect_provider.github.arn
}

output "github_actions_ecr_push_role_name" {
  description = "Name of the IAM role assumed by GitHub Actions."
  value       = aws_iam_role.github_actions_ecr_push.name
}

output "github_actions_ecr_push_role_arn" {
  description = "ARN of the IAM role assumed by GitHub Actions."
  value       = aws_iam_role.github_actions_ecr_push.arn
}

output "github_actions_ecr_push_policy_arn" {
  description = "ARN of the least-privilege ECR publishing policy."
  value       = aws_iam_policy.github_actions_ecr_push.arn
}

output "github_oidc_subject" {
  description = "GitHub OIDC subject allowed to assume the publishing role."
  value       = local.github_oidc_subject
}

output "terraform_state_key" {
  description = "S3 object key used by the shared Terraform root module."
  value       = "shared/terraform.tfstate"
}
