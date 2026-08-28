resource "aws_lb" "this" {
  name = "${var.name}-alb"

  internal           = false
  load_balancer_type = "application"
  ip_address_type    = "ipv4"

  subnets         = sort(tolist(var.subnet_ids))
  security_groups = sort(tolist(var.security_group_ids))

  drop_invalid_header_fields = true
  enable_deletion_protection = false
  enable_http2               = true
  idle_timeout               = 60

  tags = merge(var.tags, {
    Name = "${var.name}-alb"
    Tier = "public"
  })
}

resource "aws_lb_target_group" "this" {
  for_each = var.target_groups

  name = "${var.name}-${substr(each.key, 0, 4)}-tg"

  vpc_id      = var.vpc_id
  target_type = "ip"

  port             = each.value.port
  protocol         = each.value.protocol
  protocol_version = "HTTP1"

  deregistration_delay = each.value.deregistration_delay

  health_check {
    enabled = true

    protocol = each.value.protocol
    port     = "traffic-port"
    path     = each.value.health_check_path
    matcher  = each.value.health_check_matcher

    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = merge(var.tags, {
    Name    = "${var.name}-${substr(each.key, 0, 4)}-tg"
    Service = each.key
  })
}

# This temporary portfolio environment intentionally uses the generated ALB DNS name over HTTP.
# HTTPS requires a custom domain, which is intentionally outside the project's cost scope.
#trivy:ignore:AWS-0054
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn

  port     = var.listener_port
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[var.default_target_group_key].arn
  }

  tags = merge(var.tags, {
    Name = "${var.name}-http-listener"
  })
}

resource "aws_lb_listener_rule" "this" {
  for_each = var.listener_rules

  listener_arn = aws_lb_listener.http.arn
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.value.target_group_key].arn
  }

  condition {
    path_pattern {
      values = each.value.path_patterns
    }
  }

  dynamic "transform" {
    for_each = each.value.url_rewrite == null ? [] : [each.value.url_rewrite]

    content {
      type = "url-rewrite"

      url_rewrite_config {
        rewrite {
          regex   = transform.value.regex
          replace = transform.value.replace
        }
      }
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name}-${each.key}-rule"
  })
}
