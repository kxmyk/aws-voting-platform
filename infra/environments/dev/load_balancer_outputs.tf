output "alb_arn" {
  description = "ARN of the public Application Load Balancer."
  value       = module.alb.arn
}

output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer."
  value       = module.alb.dns_name
}

output "alb_zone_id" {
  description = "Canonical hosted zone ID of the Application Load Balancer."
  value       = module.alb.zone_id
}

output "alb_http_listener_arn" {
  description = "ARN of the public HTTP listener."
  value       = module.alb.http_listener_arn
}

output "alb_target_group_arns" {
  description = "Application target group ARNs indexed by service."
  value       = module.alb.target_group_arns
}

output "alb_target_group_names" {
  description = "Target group names indexed by service."
  value       = module.alb.target_group_names
}

output "application_urls" {
  description = "Public development URLs exposed through the Application Load Balancer."

  value = {
    vote   = "http://${module.alb.dns_name}/"
    result = "http://${module.alb.dns_name}/results"
  }
}
