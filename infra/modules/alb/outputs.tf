output "arn" {
  description = "ARN of the Application Load Balancer."
  value       = aws_lb.this.arn
}

output "dns_name" {
  description = "Public DNS name of the Application Load Balancer."
  value       = aws_lb.this.dns_name
}

output "zone_id" {
  description = "Canonical hosted zone ID of the Application Load Balancer."
  value       = aws_lb.this.zone_id
}

output "http_listener_arn" {
  description = "ARN of the public HTTP listener."
  value       = aws_lb_listener.http.arn
}

output "target_group_arns" {
  description = "Target group ARNs indexed by application service."

  value = {
    for service_name, target_group in aws_lb_target_group.this :
    service_name => target_group.arn
  }
}

output "target_group_names" {
  description = "Target group names indexed by application service."

  value = {
    for service_name, target_group in aws_lb_target_group.this :
    service_name => target_group.name
  }
}
