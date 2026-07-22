output "state_bucket_name" {
  description = "Name of the S3 bucket used for Terraform state."
  value       = aws_s3_bucket.terraform_state.id
}

output "state_bucket_arn" {
  description = "ARN of the S3 bucket used for Terraform state."
  value       = aws_s3_bucket.terraform_state.arn
}

output "aws_region" {
  description = "AWS region containing the Terraform state bucket."
  value       = var.aws_region
}

output "development_state_key" {
  description = "Recommended S3 object key for the development environment state."
  value       = "environments/dev/terraform.tfstate"
}
