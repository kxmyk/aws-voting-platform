#!/usr/bin/env bash

set -Eeuo pipefail

readonly CLEANUP_MODE="${1:---dry-run}"
readonly CLEANUP_AWS_REGION="${AWS_REGION:-eu-central-1}"
readonly CLEANUP_PROJECT_NAME="${PROJECT_NAME:-aws-voting-platform}"
readonly CLEANUP_ENVIRONMENT="${ECS_ENVIRONMENT:-dev}"

case "${CLEANUP_MODE}" in
  --dry-run | --execute)
    ;;
  *)
    echo "Usage: $0 [--dry-run|--execute]"
    exit 1
    ;;
esac

if ! command -v aws >/dev/null 2>&1; then
  echo "Required command is not installed: aws"
  exit 1
fi

readonly SERVICES=(
  vote
  result
  worker
)

MATCHED_COUNT=0
DEREGISTERED_COUNT=0

for service_name in "${SERVICES[@]}"; do
  task_definition_family="${CLEANUP_PROJECT_NAME}-${CLEANUP_ENVIRONMENT}-${service_name}"

  task_definition_arns="$(
    aws ecs list-task-definitions \
      --region "${CLEANUP_AWS_REGION}" \
      --family-prefix "${task_definition_family}" \
      --status ACTIVE \
      --sort DESC \
      --query taskDefinitionArns \
      --output text
  )"

  if [[ -z "${task_definition_arns}" || "${task_definition_arns}" == "None" ]]; then
    continue
  fi

  for task_definition_arn in ${task_definition_arns}; do
    managed_by="$(
      aws ecs list-tags-for-resource \
        --region "${CLEANUP_AWS_REGION}" \
        --resource-arn "${task_definition_arn}" \
        --query "tags[?key=='ManagedBy'].value | [0]" \
        --output text
    )"

    tagged_project="$(
      aws ecs list-tags-for-resource \
        --region "${CLEANUP_AWS_REGION}" \
        --resource-arn "${task_definition_arn}" \
        --query "tags[?key=='Project'].value | [0]" \
        --output text
    )"

    tagged_environment="$(
      aws ecs list-tags-for-resource \
        --region "${CLEANUP_AWS_REGION}" \
        --resource-arn "${task_definition_arn}" \
        --query "tags[?key=='Environment'].value | [0]" \
        --output text
    )"

    if [[ "${managed_by}" != "GitHubActions" ]]; then
      continue
    fi

    if [[ "${tagged_project}" != "${CLEANUP_PROJECT_NAME}" ]]; then
      continue
    fi

    if [[ "${tagged_environment}" != "${CLEANUP_ENVIRONMENT}" ]]; then
      continue
    fi

    MATCHED_COUNT=$((MATCHED_COUNT + 1))

    if [[ "${CLEANUP_MODE}" == "--dry-run" ]]; then
      echo "Would deregister: ${task_definition_arn}"
      continue
    fi

    aws ecs deregister-task-definition \
      --region "${CLEANUP_AWS_REGION}" \
      --task-definition "${task_definition_arn}" \
      --query taskDefinition.taskDefinitionArn \
      --output text

    DEREGISTERED_COUNT=$((DEREGISTERED_COUNT + 1))
  done
done

echo
echo "Matching GitHub Actions task definitions: ${MATCHED_COUNT}"

if [[ "${CLEANUP_MODE}" == "--dry-run" ]]; then
  echo "Dry run only. Nothing was deregistered."
else
  echo "Deregistered task definitions: ${DEREGISTERED_COUNT}"
fi
