output "repository_names" {
  description = "ECR repository names indexed by service name."

  value = {
    for service_name, repository in aws_ecr_repository.this :
    service_name => repository.name
  }
}

output "repository_urls" {
  description = "ECR repository URLs indexed by service name."

  value = {
    for service_name, repository in aws_ecr_repository.this :
    service_name => repository.repository_url
  }
}

output "repository_arns" {
  description = "ECR repository ARNs indexed by service name."

  value = {
    for service_name, repository in aws_ecr_repository.this :
    service_name => repository.arn
  }
}

output "registry_ids" {
  description = "ECR registry IDs indexed by service name."

  value = {
    for service_name, repository in aws_ecr_repository.this :
    service_name => repository.registry_id
  }
}
