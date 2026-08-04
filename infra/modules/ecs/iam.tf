data "aws_iam_policy_document" "ecs_tasks_assume_role" {
  statement {
    sid    = "AllowEcsTasksToAssumeRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"

      identifiers = [
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "task_execution" {
  name = "${var.name}-task-execution-role"
  path = "/ecs/"

  description = "Allows Amazon ECS to pull application images and publish container logs."

  assume_role_policy    = data.aws_iam_policy_document.ecs_tasks_assume_role.json
  force_detach_policies = true

  tags = merge(var.tags, {
    Name = "${var.name}-task-execution-role"
    Type = "task-execution"
  })
}

data "aws_iam_policy_document" "task_execution" {
  statement {
    sid    = "GetEcrAuthorizationToken"
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid    = "PullApplicationImages"
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer"
    ]

    resources = var.ecr_repository_arns
  }

  statement {
    sid    = "WriteContainerLogs"
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = local.log_stream_arns
  }
}

resource "aws_iam_policy" "task_execution" {
  name = "${var.name}-task-execution"
  path = "/ecs/"

  description = "Least-privilege permissions used by Amazon ECS when starting application tasks."

  policy = data.aws_iam_policy_document.task_execution.json

  tags = merge(var.tags, {
    Name = "${var.name}-task-execution"
    Type = "task-execution"
  })
}

resource "aws_iam_role_policy_attachment" "task_execution" {
  role       = aws_iam_role.task_execution.name
  policy_arn = aws_iam_policy.task_execution.arn
}

resource "aws_iam_role" "task" {
  for_each = var.service_names

  name = "${var.name}-${each.key}-task-role"
  path = "/ecs/"

  description = "Application IAM role used by the ${each.key} ECS task."

  assume_role_policy    = data.aws_iam_policy_document.ecs_tasks_assume_role.json
  force_detach_policies = true

  tags = merge(var.tags, {
    Name    = "${var.name}-${each.key}-task-role"
    Type    = "task"
    Service = each.key
  })
}
