resource "aws_security_group" "alb" {
  name                   = "${var.name}-alb-sg"
  description            = "Controls public ingress and application egress for the Application Load Balancer."
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true

  tags = merge(var.tags, {
    Name = "${var.name}-alb-sg"
    Tier = "public"
  })
}

resource "aws_security_group" "vote" {
  name                   = "${var.name}-vote-sg"
  description            = "Controls traffic to and from the vote application."
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true

  tags = merge(var.tags, {
    Name    = "${var.name}-vote-sg"
    Tier    = "application"
    Service = "vote"
  })
}

resource "aws_security_group" "result" {
  name                   = "${var.name}-result-sg"
  description            = "Controls traffic to and from the result application."
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true

  tags = merge(var.tags, {
    Name    = "${var.name}-result-sg"
    Tier    = "application"
    Service = "result"
  })
}

resource "aws_security_group" "worker" {
  name                   = "${var.name}-worker-sg"
  description            = "Controls outbound traffic from the background worker."
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true

  tags = merge(var.tags, {
    Name    = "${var.name}-worker-sg"
    Tier    = "application"
    Service = "worker"
  })
}

resource "aws_security_group" "redis" {
  name                   = "${var.name}-redis-sg"
  description            = "Allows Redis access only from authorized application services."
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true

  tags = merge(var.tags, {
    Name    = "${var.name}-redis-sg"
    Tier    = "data"
    Service = "redis"
  })
}

resource "aws_security_group" "postgres" {
  name                   = "${var.name}-postgres-sg"
  description            = "Allows PostgreSQL access only from authorized application services."
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true

  tags = merge(var.tags, {
    Name    = "${var.name}-postgres-sg"
    Tier    = "data"
    Service = "postgres"
  })
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  for_each = toset(var.alb_ingress_ipv4_cidrs)

  security_group_id = aws_security_group.alb.id
  description       = "Allow public HTTP traffic from ${each.value}."

  cidr_ipv4   = each.value
  from_port   = var.http_port
  ip_protocol = "tcp"
  to_port     = var.http_port
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  for_each = (
    var.enable_https_ingress
    ? toset(var.alb_ingress_ipv4_cidrs)
    : toset([])
  )

  security_group_id = aws_security_group.alb.id
  description       = "Allow public HTTPS traffic from ${each.value}."

  cidr_ipv4   = each.value
  from_port   = var.https_port
  ip_protocol = "tcp"
  to_port     = var.https_port
}

resource "aws_vpc_security_group_egress_rule" "alb_to_vote" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow the load balancer to reach the vote application."

  referenced_security_group_id = aws_security_group.vote.id
  from_port                    = var.vote_port
  ip_protocol                  = "tcp"
  to_port                      = var.vote_port
}

resource "aws_vpc_security_group_egress_rule" "alb_to_result" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow the load balancer to reach the result application."

  referenced_security_group_id = aws_security_group.result.id
  from_port                    = var.result_port
  ip_protocol                  = "tcp"
  to_port                      = var.result_port
}

resource "aws_vpc_security_group_ingress_rule" "vote_from_alb" {
  security_group_id = aws_security_group.vote.id
  description       = "Allow vote application traffic from the load balancer."

  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = var.vote_port
  ip_protocol                  = "tcp"
  to_port                      = var.vote_port
}

resource "aws_vpc_security_group_ingress_rule" "result_from_alb" {
  security_group_id = aws_security_group.result.id
  description       = "Allow result application traffic from the load balancer."

  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = var.result_port
  ip_protocol                  = "tcp"
  to_port                      = var.result_port
}

resource "aws_vpc_security_group_egress_rule" "vote_to_redis" {
  security_group_id = aws_security_group.vote.id
  description       = "Allow the vote application to connect to Redis."

  referenced_security_group_id = aws_security_group.redis.id
  from_port                    = var.redis_port
  ip_protocol                  = "tcp"
  to_port                      = var.redis_port
}

resource "aws_vpc_security_group_egress_rule" "result_to_postgres" {
  security_group_id = aws_security_group.result.id
  description       = "Allow the result application to connect to PostgreSQL."

  referenced_security_group_id = aws_security_group.postgres.id
  from_port                    = var.postgres_port
  ip_protocol                  = "tcp"
  to_port                      = var.postgres_port
}

resource "aws_vpc_security_group_egress_rule" "worker_to_redis" {
  security_group_id = aws_security_group.worker.id
  description       = "Allow the worker to connect to Redis."

  referenced_security_group_id = aws_security_group.redis.id
  from_port                    = var.redis_port
  ip_protocol                  = "tcp"
  to_port                      = var.redis_port
}

resource "aws_vpc_security_group_egress_rule" "worker_to_postgres" {
  security_group_id = aws_security_group.worker.id
  description       = "Allow the worker to connect to PostgreSQL."

  referenced_security_group_id = aws_security_group.postgres.id
  from_port                    = var.postgres_port
  ip_protocol                  = "tcp"
  to_port                      = var.postgres_port
}

resource "aws_vpc_security_group_egress_rule" "vote_https" {
  security_group_id = aws_security_group.vote.id
  description       = "Allow outbound HTTPS traffic from the vote application."

  cidr_ipv4   = var.application_https_egress_ipv4_cidr
  from_port   = var.https_port
  ip_protocol = "tcp"
  to_port     = var.https_port
}

resource "aws_vpc_security_group_egress_rule" "result_https" {
  security_group_id = aws_security_group.result.id
  description       = "Allow outbound HTTPS traffic from the result application."

  cidr_ipv4   = var.application_https_egress_ipv4_cidr
  from_port   = var.https_port
  ip_protocol = "tcp"
  to_port     = var.https_port
}

resource "aws_vpc_security_group_egress_rule" "worker_https" {
  security_group_id = aws_security_group.worker.id
  description       = "Allow outbound HTTPS traffic from the worker."

  cidr_ipv4   = var.application_https_egress_ipv4_cidr
  from_port   = var.https_port
  ip_protocol = "tcp"
  to_port     = var.https_port
}

resource "aws_vpc_security_group_ingress_rule" "redis_from_vote" {
  security_group_id = aws_security_group.redis.id
  description       = "Allow Redis connections from the vote application."

  referenced_security_group_id = aws_security_group.vote.id
  from_port                    = var.redis_port
  ip_protocol                  = "tcp"
  to_port                      = var.redis_port
}

resource "aws_vpc_security_group_ingress_rule" "redis_from_worker" {
  security_group_id = aws_security_group.redis.id
  description       = "Allow Redis connections from the worker."

  referenced_security_group_id = aws_security_group.worker.id
  from_port                    = var.redis_port
  ip_protocol                  = "tcp"
  to_port                      = var.redis_port
}

resource "aws_vpc_security_group_ingress_rule" "postgres_from_result" {
  security_group_id = aws_security_group.postgres.id
  description       = "Allow PostgreSQL connections from the result application."

  referenced_security_group_id = aws_security_group.result.id
  from_port                    = var.postgres_port
  ip_protocol                  = "tcp"
  to_port                      = var.postgres_port
}

resource "aws_vpc_security_group_ingress_rule" "postgres_from_worker" {
  security_group_id = aws_security_group.postgres.id
  description       = "Allow PostgreSQL connections from the worker."

  referenced_security_group_id = aws_security_group.worker.id
  from_port                    = var.postgres_port
  ip_protocol                  = "tcp"
  to_port                      = var.postgres_port
}
