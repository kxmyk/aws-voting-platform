# Automated ECS deployment

The deployment workflow updates the `vote`, `result` and `worker` ECS services with immutable ECR image digests.

## Deployment flow

1. The ECR publishing workflow builds images from `main`.
2. Images receive the tag `sha-<first-12-characters-of-git-sha>`.
3. The ECS deployment workflow verifies the image in ECR.
4. It resolves the immutable image digest.
5. It downloads the currently active task definition.
6. It changes only the selected container image.
7. It registers a new task definition revision.
8. It updates the corresponding ECS service.
9. It waits for ECS service stability.
10. It verifies the active revision and image digest.

## Authentication

GitHub Actions uses OpenID Connect and temporary AWS credentials.

The ECS deployment role:

- trusts only the immutable OIDC subject for the `main` branch;
- can inspect only the project ECR repositories;
- can register only the three project task definition families;
- can update only the three development ECS services;
- can pass only the project ECS task and execution roles;
- can pass those roles only to `ecs-tasks.amazonaws.com`.

The ECR publishing role and ECS deployment role remain separate.

## GitHub repository variables

Required:

```text
AWS_ECS_DEPLOY_ROLE_ARN
```

Optional automatic deployment switch:

```text
ECS_AUTO_DEPLOY
```

When `ECS_AUTO_DEPLOY` equals `true`, a successful `Publish images to Amazon ECR` workflow run on `main` automatically starts ECS deployment.

Keep the value `false` while the temporary development environment is destroyed.

## Manual deployment

The workflow supports `workflow_dispatch` with:

- a full source commit SHA;
- `all`, `vote`, `result` or `worker`.

Example:

```bash
gh workflow run deploy-ecs.yaml \
  --ref main \
  -f source_sha=<full-commit-sha> \
  -f service=all
```

## Terraform state alignment

Terraform creates the initial task definition revisions.

GitHub Actions creates subsequent application deployment revisions.

The development Terraform root reads the latest active revision with the `aws_ecs_task_definition` data source. ECS services therefore remain aligned with the latest CI-created revision instead of being reverted to the bootstrap revision during the next Terraform plan.

Terraform continues to own:

- task definition configuration;
- ECS services;
- network configuration;
- IAM roles;
- security groups;
- load balancer integration.

GitHub Actions changes only the container image and creates a new revision from the currently active task definition.

## Local deployment test

The same script used by GitHub Actions can be tested locally:

```bash
export AWS_PROFILE=aws-voting-platform

bash scripts/deploy-ecs-service.sh \
  vote \
  <full-source-commit-sha>
```

## Cleanup

Task definitions registered by the deployment script receive:

```text
ManagedBy=GitHubActions
Project=aws-voting-platform
Environment=dev
```

Preview cleanup:

```bash
bash scripts/cleanup-ecs-task-definitions.sh --dry-run
```

Deregister matching active revisions:

```bash
bash scripts/cleanup-ecs-task-definitions.sh --execute
```

The cleanup script ignores Terraform-managed task definitions and unrelated projects.
