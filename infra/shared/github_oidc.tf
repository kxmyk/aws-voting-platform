resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-github-oidc"
  })
}

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    sid    = "GitHubActionsAssumeRoleWithWebIdentity"
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
        local.github_oidc_subject
      ]
    }
  }
}

resource "aws_iam_role" "github_actions_ecr_push" {
  name = "${var.project_name}-github-ecr-push"
  path = "/github-actions/"

  description = "Allows the main branch of the AWS Voting Platform repository to publish container images to ECR."

  assume_role_policy    = data.aws_iam_policy_document.github_actions_assume_role.json
  max_session_duration  = 3600
  force_detach_policies = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-github-ecr-push"
  })
}

data "aws_iam_policy_document" "github_actions_ecr_push" {
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
    sid    = "PushImagesToProjectRepositories"
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]

    resources = values(module.ecr.repository_arns)
  }
}

resource "aws_iam_policy" "github_actions_ecr_push" {
  name = "${var.project_name}-github-ecr-push"
  path = "/github-actions/"

  description = "Allows GitHub Actions to publish images only to the AWS Voting Platform ECR repositories."

  policy = data.aws_iam_policy_document.github_actions_ecr_push.json

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-github-ecr-push"
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_ecr_push" {
  role       = aws_iam_role.github_actions_ecr_push.name
  policy_arn = aws_iam_policy.github_actions_ecr_push.arn
}
