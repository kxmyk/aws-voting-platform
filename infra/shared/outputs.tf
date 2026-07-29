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

output "terraform_state_key" {
  description = "S3 object key used by the shared Terraform root module."
  value       = "shared/terraform.tfstate"
}
