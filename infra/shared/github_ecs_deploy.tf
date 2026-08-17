data "aws_partition" "current" {}

locals {
  github_ecs_deployment_name_prefix = join("-", [
    var.project_name,
    var.github_ecs_deployment_environment
  ])

  github_ecs_deployment_cluster_name = (
    "${local.github_ecs_deployment_name_prefix}-cluster"
  )

  github_ecs_deployment_service_names = {
    for service_name in var.service_names :
    service_name => join("-", [
      local.github_ecs_deployment_name_prefix,
      service_name
    ])
  }

  github_ecs_deployment_service_arns = {
    for service_name, ecs_service_name
    in local.github_ecs_deployment_service_names :
    service_name => join("", [
      "arn:",
      data.aws_partition.current.partition,
      ":ecs:",
      var.aws_region,
      ":",
      data.aws_caller_identity.current.account_id,
      ":service/",
      local.github_ecs_deployment_cluster_name,
      "/",
      ecs_service_name
    ])
  }

  github_ecs_deployment_task_definition_arns = {
    for service_name in var.service_names :
    service_name => join("", [
      "arn:",
      data.aws_partition.current.partition,
      ":ecs:",
      var.aws_region,
      ":",
      data.aws_caller_identity.current.account_id,
      ":task-definition/",
      local.github_ecs_deployment_name_prefix,
      "-",
      service_name,
      ":*"
    ])
  }

  github_ecs_deployment_task_role_arns = {
    for service_name in var.service_names :
    service_name => join("", [
      "arn:",
      data.aws_partition.current.partition,
      ":iam::",
      data.aws_caller_identity.current.account_id,
      ":role/ecs/",
      local.github_ecs_deployment_name_prefix,
      "-",
      service_name,
      "-task-role"
    ])
  }

  github_ecs_deployment_execution_role_arn = join("", [
    "arn:",
    data.aws_partition.current.partition,
    ":iam::",
    data.aws_caller_identity.current.account_id,
    ":role/ecs/",
    local.github_ecs_deployment_name_prefix,
    "-task-execution-role"
  ])
}

data "aws_iam_policy_document" "github_actions_ecs_deploy_assume_role" {
  statement {
    sid    = "GitHubActionsEcsDeployAssumeRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        local.github_main_oidc_subject
      ]
    }
  }
}

resource "aws_iam_role" "github_actions_ecs_deploy" {
  name = "${var.project_name}-github-ecs-deploy"
  path = "/github-actions/"

  description = "Allows the main branch of the AWS Voting Platform repository to deploy application revisions to ECS."

  assume_role_policy    = data.aws_iam_policy_document.github_actions_ecs_deploy_assume_role.json
  max_session_duration  = 3600
  force_detach_policies = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-github-ecs-deploy"
  })
}

data "aws_iam_policy_document" "github_actions_ecs_deploy" {
  statement {
    sid    = "ReadProjectImages"
    effect = "Allow"

    actions = [
      "ecr:DescribeImages"
    ]

    resources = values(module.ecr.repository_arns)
  }

  statement {
    sid    = "ReadTaskDefinitions"
    effect = "Allow"

    actions = [
      "ecs:DescribeTaskDefinition"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid    = "RegisterProjectTaskDefinitions"
    effect = "Allow"

    actions = [
      "ecs:RegisterTaskDefinition"
    ]

    resources = values(
      local.github_ecs_deployment_task_definition_arns
    )
  }

  statement {
    sid    = "TagRegisteredTaskDefinitions"
    effect = "Allow"

    actions = [
      "ecs:TagResource"
    ]

    resources = values(
      local.github_ecs_deployment_task_definition_arns
    )

    condition {
      test     = "StringEquals"
      variable = "ecs:CreateAction"

      values = [
        "RegisterTaskDefinition"
      ]
    }
  }

  statement {
    sid    = "DeployProjectServices"
    effect = "Allow"

    actions = [
      "ecs:DescribeServices",
      "ecs:UpdateService"
    ]

    resources = values(
      local.github_ecs_deployment_service_arns
    )
  }

  statement {
    sid    = "PassProjectTaskRolesToEcs"
    effect = "Allow"

    actions = [
      "iam:PassRole"
    ]

    resources = concat(
      [
        local.github_ecs_deployment_execution_role_arn
      ],
      values(local.github_ecs_deployment_task_role_arns)
    )

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"

      values = [
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_policy" "github_actions_ecs_deploy" {
  name = "${var.project_name}-github-ecs-deploy"
  path = "/github-actions/"

  description = "Allows GitHub Actions to deploy only the AWS Voting Platform development ECS services."

  policy = data.aws_iam_policy_document.github_actions_ecs_deploy.json

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-github-ecs-deploy"
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_ecs_deploy" {
  role       = aws_iam_role.github_actions_ecs_deploy.name
  policy_arn = aws_iam_policy.github_actions_ecs_deploy.arn
}
