output "id" {
  description = "ID of the ECS service."
  value       = aws_ecs_service.this.id
}

output "name" {
  description = "Name of the ECS service."
  value       = aws_ecs_service.this.name
}

output "arn" {
  description = "ARN of the ECS service."
  value       = aws_ecs_service.this.arn
}

output "desired_count" {
  description = "Desired number of tasks configured for the ECS service."
  value       = aws_ecs_service.this.desired_count
}
