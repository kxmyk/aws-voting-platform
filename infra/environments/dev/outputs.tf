output "project_name" {
  description = "Project name used by the environment."
  value       = var.project_name
}

output "environment" {
  description = "Current deployment environment."
  value       = var.environment
}

output "aws_region" {
  description = "AWS region used by the environment."
  value       = var.aws_region
}

output "aws_account_id" {
  description = "AWS account ID used by Terraform."
  value       = data.aws_caller_identity.current.account_id
}

output "terraform_state_key" {
  description = "S3 object key used for this environment's Terraform state."
  value       = "environments/dev/terraform.tfstate"
}
