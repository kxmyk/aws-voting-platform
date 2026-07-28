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

output "vpc_id" {
  description = "ID of the development VPC."
  value       = module.network.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block assigned to the development VPC."
  value       = module.network.vpc_cidr_block
}

output "availability_zones" {
  description = "Availability zones used by the development network."
  value       = module.network.availability_zones
}

output "internet_gateway_id" {
  description = "ID of the development Internet Gateway."
  value       = module.network.internet_gateway_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs indexed by availability zone."
  value       = module.network.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "Private application subnet IDs indexed by availability zone."
  value       = module.network.private_app_subnet_ids
}

output "private_data_subnet_ids" {
  description = "Private data subnet IDs indexed by availability zone."
  value       = module.network.private_data_subnet_ids
}

output "nat_gateway_mode" {
  description = "Configured NAT Gateway deployment mode."
  value       = module.network.nat_gateway_mode
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs indexed by availability zone."
  value       = module.network.nat_gateway_ids
}

output "nat_gateway_public_ips" {
  description = "Public IP addresses assigned to NAT Gateways."
  value       = module.network.nat_gateway_public_ips
}

output "alb_security_group_id" {
  description = "Security group ID assigned to the Application Load Balancer."
  value       = module.security.alb_security_group_id
}

output "vote_security_group_id" {
  description = "Security group ID assigned to the vote application."
  value       = module.security.vote_security_group_id
}

output "result_security_group_id" {
  description = "Security group ID assigned to the result application."
  value       = module.security.result_security_group_id
}

output "worker_security_group_id" {
  description = "Security group ID assigned to the worker."
  value       = module.security.worker_security_group_id
}

output "redis_security_group_id" {
  description = "Security group ID assigned to Redis."
  value       = module.security.redis_security_group_id
}

output "postgres_security_group_id" {
  description = "Security group ID assigned to PostgreSQL."
  value       = module.security.postgres_security_group_id
}

output "security_group_ids" {
  description = "Map of security group IDs created for the application."
  value       = module.security.security_group_ids
}
