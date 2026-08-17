#!/usr/bin/env bash

set -Eeuo pipefail

usage() {
  echo "Usage: $0 <vote|result|worker> <40-character-source-sha>" >&2
}

die() {
  echo "Error: $*" >&2
  exit 1
}

require_command() {
  local command_name="$1"

  command -v "$command_name" >/dev/null 2>&1 ||
    die "Required command is not installed: $command_name"
}

describe_service() {
  aws ecs describe-services \
    --region "$AWS_REGION" \
    --cluster "$ECS_CLUSTER_NAME" \
    --services "$ECS_SERVICE_NAME" \
    --output json
}

print_service_diagnostics() {
  local service_json="$1"

  jq '.services[0] | {
    status,
    desiredCount,
    runningCount,
    pendingCount,
    taskDefinition,
    deployments: [
      .deployments[] | {
        id,
        status,
        taskDefinition,
        desiredCount,
        runningCount,
        pendingCount,
        failedTasks,
        rolloutState,
        rolloutStateReason
      }
    ],
    events: .events[:15]
  }' <<<"$service_json" >&2
}

if [[ "$#" -ne 2 ]]; then
  usage
  exit 1
fi

SERVICE_NAME="$1"
SOURCE_SHA="$2"

case "$SERVICE_NAME" in
  vote | result | worker)
    ;;
  *)
    die "Unsupported ECS service: $SERVICE_NAME"
    ;;
esac

if [[ ! "$SOURCE_SHA" =~ ^[0-9a-f]{40}$ ]]; then
  die "Source SHA must contain exactly 40 lowercase hexadecimal characters."
fi

require_command aws
require_command jq
require_command mktemp

AWS_REGION="${AWS_REGION:-eu-central-1}"
PROJECT_NAME="${PROJECT_NAME:-aws-voting-platform}"
ENVIRONMENT="${ENVIRONMENT:-dev}"
GITHUB_REPOSITORY="${GITHUB_REPOSITORY:-kxmyk/aws-voting-platform}"

ECS_CLUSTER_NAME="${ECS_CLUSTER_NAME:-${PROJECT_NAME}-${ENVIRONMENT}-cluster}"
ECS_SERVICE_NAME="${PROJECT_NAME}-${ENVIRONMENT}-${SERVICE_NAME}"

ECR_REPOSITORY_NAME="${PROJECT_NAME}/${SERVICE_NAME}"
IMAGE_TAG="sha-${SOURCE_SHA:0:12}"

DEPLOYMENT_TIMEOUT_SECONDS="${ECS_DEPLOYMENT_TIMEOUT_SECONDS:-900}"
DEPLOYMENT_POLL_SECONDS="${ECS_DEPLOYMENT_POLL_SECONDS:-10}"

if [[ ! "$DEPLOYMENT_TIMEOUT_SECONDS" =~ ^[1-9][0-9]*$ ]]; then
  die "ECS_DEPLOYMENT_TIMEOUT_SECONDS must be a positive integer."
fi

if [[ ! "$DEPLOYMENT_POLL_SECONDS" =~ ^[1-9][0-9]*$ ]]; then
  die "ECS_DEPLOYMENT_POLL_SECONDS must be a positive integer."
fi

AWS_ACCOUNT_ID="$(
  aws sts get-caller-identity \
    --region "$AWS_REGION" \
    --query Account \
    --output text
)"

if [[ ! "$AWS_ACCOUNT_ID" =~ ^[0-9]{12}$ ]]; then
  die "Unable to determine the AWS account ID."
fi

IMAGE_DIGEST="$(
  aws ecr describe-images \
    --region "$AWS_REGION" \
    --repository-name "$ECR_REPOSITORY_NAME" \
    --image-ids "imageTag=$IMAGE_TAG" \
    --query 'imageDetails[0].imageDigest' \
    --output text
)"

if [[ ! "$IMAGE_DIGEST" =~ ^sha256:[0-9a-f]{64}$ ]]; then
  die "Image $ECR_REPOSITORY_NAME:$IMAGE_TAG was not found."
fi

IMAGE_URI="$(
  printf '%s.dkr.ecr.%s.amazonaws.com/%s@%s' \
    "$AWS_ACCOUNT_ID" \
    "$AWS_REGION" \
    "$ECR_REPOSITORY_NAME" \
    "$IMAGE_DIGEST"
)"

SERVICE_JSON="$(describe_service)"

if [[ "$(jq '.failures | length' <<<"$SERVICE_JSON")" -ne 0 ]]; then
  print_service_diagnostics "$SERVICE_JSON"
  die "Unable to describe ECS service $ECS_SERVICE_NAME."
fi

SERVICE_STATUS="$(
  jq -r '.services[0].status // empty' <<<"$SERVICE_JSON"
)"

if [[ "$SERVICE_STATUS" != "ACTIVE" ]]; then
  print_service_diagnostics "$SERVICE_JSON"
  die "ECS service $ECS_SERVICE_NAME is not ACTIVE."
fi

PREVIOUS_TASK_DEFINITION_ARN="$(
  jq -r '.services[0].taskDefinition' <<<"$SERVICE_JSON"
)"

DEPLOY_TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$DEPLOY_TMP_DIR"' EXIT

CURRENT_TASK_DEFINITION_FILE="$DEPLOY_TMP_DIR/current-task-definition.json"
REGISTER_INPUT_FILE="$DEPLOY_TMP_DIR/register-task-definition.json"

aws ecs describe-task-definition \
  --region "$AWS_REGION" \
  --task-definition "$PREVIOUS_TASK_DEFINITION_ARN" \
  --output json \
  >"$CURRENT_TASK_DEFINITION_FILE"

CONTAINER_MATCH_COUNT="$(
  jq \
    --arg container_name "$SERVICE_NAME" \
    '[
      .taskDefinition.containerDefinitions[]
      | select(.name == $container_name)
    ] | length' \
    "$CURRENT_TASK_DEFINITION_FILE"
)"

if [[ "$CONTAINER_MATCH_COUNT" -ne 1 ]]; then
  die "Task Definition must contain exactly one container named $SERVICE_NAME."
fi

jq \
  --arg container_name "$SERVICE_NAME" \
  --arg image_uri "$IMAGE_URI" \
  '
    .taskDefinition
    | {
        family,
        taskRoleArn,
        executionRoleArn,
        networkMode,
        containerDefinitions,
        volumes,
        placementConstraints,
        requiresCompatibilities,
        cpu,
        memory,
        pidMode,
        ipcMode,
        proxyConfiguration,
        inferenceAccelerators,
        ephemeralStorage,
        runtimePlatform,
        enableFaultInjection
      }
    | .containerDefinitions |= map(
        if .name == $container_name
        then .image = $image_uri
        else .
        end
      )
    | with_entries(select(.value != null))
  ' \
  "$CURRENT_TASK_DEFINITION_FILE" \
  >"$REGISTER_INPUT_FILE"

REGISTER_RESPONSE="$(
  aws ecs register-task-definition \
    --region "$AWS_REGION" \
    --cli-input-json "file://$REGISTER_INPUT_FILE" \
    --tags \
      "key=ManagedBy,value=GitHubActions" \
      "key=Project,value=$PROJECT_NAME" \
      "key=Environment,value=$ENVIRONMENT" \
      "key=Repository,value=$GITHUB_REPOSITORY" \
      "key=Service,value=$SERVICE_NAME" \
      "key=SourceCommit,value=$SOURCE_SHA" \
    --output json
)"

NEW_TASK_DEFINITION_ARN="$(
  jq -r '.taskDefinition.taskDefinitionArn // empty' \
    <<<"$REGISTER_RESPONSE"
)"

if [[ -z "$NEW_TASK_DEFINITION_ARN" ]]; then
  die "AWS did not return the registered Task Definition ARN."
fi

UPDATE_RESPONSE="$(
  aws ecs update-service \
    --region "$AWS_REGION" \
    --cluster "$ECS_CLUSTER_NAME" \
    --service "$ECS_SERVICE_NAME" \
    --task-definition "$NEW_TASK_DEFINITION_ARN" \
    --output json
)"

aws ecs describe-services \
  --region "$AWS_REGION" \
  --cluster "$ECS_CLUSTER_NAME" \
  --services "$ECS_SERVICE_NAME" \
  --query 'services[0].{
    Service:serviceName,
    Desired:desiredCount,
    Running:runningCount,
    Pending:pendingCount,
    TaskDefinition:taskDefinition
  }' \
  --output table

DEPLOYMENT_ID="$(
  jq \
    --arg task_definition "$NEW_TASK_DEFINITION_ARN" \
    -r '
      first(
        .service.deployments[]
        | select(.taskDefinition == $task_definition)
        | .id
      ) // empty
    ' \
    <<<"$UPDATE_RESPONSE"
)"

if [[ -z "$DEPLOYMENT_ID" ]]; then
  echo "Waiting for the new ECS deployment to become visible."

  for ((attempt = 1; attempt <= 12; attempt++)); do
    SERVICE_JSON="$(describe_service)"

    DEPLOYMENT_ID="$(
      jq \
        --arg task_definition "$NEW_TASK_DEFINITION_ARN" \
        -r '
          first(
            .services[0].deployments[]
            | select(.taskDefinition == $task_definition)
            | .id
          ) // empty
        ' \
        <<<"$SERVICE_JSON"
    )"

    if [[ -n "$DEPLOYMENT_ID" ]]; then
      break
    fi

    sleep 5
  done
fi

if [[ -z "$DEPLOYMENT_ID" ]]; then
  SERVICE_JSON="$(describe_service)"
  print_service_diagnostics "$SERVICE_JSON"
  die "Unable to identify the ECS deployment for $NEW_TASK_DEFINITION_ARN."
fi

echo
echo "Tracking ECS deployment: $DEPLOYMENT_ID"
echo "Timeout: ${DEPLOYMENT_TIMEOUT_SECONDS}s"

DEPLOYMENT_DEADLINE=$((SECONDS + DEPLOYMENT_TIMEOUT_SECONDS))
LAST_STATUS_LINE=""
DEPLOYMENT_COMPLETED=false

while ((SECONDS < DEPLOYMENT_DEADLINE)); do
  SERVICE_JSON="$(describe_service)"

  if [[ "$(jq '.failures | length' <<<"$SERVICE_JSON")" -ne 0 ]]; then
    print_service_diagnostics "$SERVICE_JSON"
    die "Unable to describe ECS service during deployment."
  fi

  DEPLOYMENT_JSON="$(
    jq \
      --arg deployment_id "$DEPLOYMENT_ID" \
      -c '
        first(
          .services[0].deployments[]
          | select(.id == $deployment_id)
        ) // empty
      ' \
      <<<"$SERVICE_JSON"
  )"

  if [[ -z "$DEPLOYMENT_JSON" ]]; then
    echo "Deployment is temporarily absent from DescribeServices; retrying."
    sleep "$DEPLOYMENT_POLL_SECONDS"
    continue
  fi

  ROLLOUT_STATE="$(
    jq -r '.rolloutState // "UNKNOWN"' <<<"$DEPLOYMENT_JSON"
  )"

  ROLLOUT_REASON="$(
    jq -r '.rolloutStateReason // ""' <<<"$DEPLOYMENT_JSON"
  )"

  DESIRED_COUNT="$(
    jq -r '.services[0].desiredCount' <<<"$SERVICE_JSON"
  )"

  RUNNING_COUNT="$(
    jq -r '.services[0].runningCount' <<<"$SERVICE_JSON"
  )"

  PENDING_COUNT="$(
    jq -r '.services[0].pendingCount' <<<"$SERVICE_JSON"
  )"

  FAILED_TASKS="$(
    jq -r '.failedTasks // 0' <<<"$DEPLOYMENT_JSON"
  )"

  ACTIVE_TASK_DEFINITION_ARN="$(
    jq -r '.services[0].taskDefinition' <<<"$SERVICE_JSON"
  )"

  STATUS_LINE="$(
    printf \
      'state=%s desired=%s running=%s pending=%s failed=%s' \
      "$ROLLOUT_STATE" \
      "$DESIRED_COUNT" \
      "$RUNNING_COUNT" \
      "$PENDING_COUNT" \
      "$FAILED_TASKS"
  )"

  if [[ "$STATUS_LINE" != "$LAST_STATUS_LINE" ]]; then
    echo "$STATUS_LINE"
    LAST_STATUS_LINE="$STATUS_LINE"
  fi

  if [[ "$ROLLOUT_STATE" == "FAILED" ]]; then
    print_service_diagnostics "$SERVICE_JSON"
    die "ECS deployment failed: $ROLLOUT_REASON"
  fi

  if [[ "$ROLLOUT_STATE" == "COMPLETED" ]] &&
    [[ "$ACTIVE_TASK_DEFINITION_ARN" == "$NEW_TASK_DEFINITION_ARN" ]] &&
    [[ "$RUNNING_COUNT" -eq "$DESIRED_COUNT" ]] &&
    [[ "$PENDING_COUNT" -eq 0 ]]; then
    DEPLOYMENT_COMPLETED=true
    break
  fi

  sleep "$DEPLOYMENT_POLL_SECONDS"
done

if [[ "$DEPLOYMENT_COMPLETED" != "true" ]]; then
  SERVICE_JSON="$(describe_service)"
  print_service_diagnostics "$SERVICE_JSON"
  die "ECS deployment did not complete within ${DEPLOYMENT_TIMEOUT_SECONDS}s."
fi

ACTIVE_IMAGE_URI="$(
  aws ecs describe-task-definition \
    --region "$AWS_REGION" \
    --task-definition "$NEW_TASK_DEFINITION_ARN" \
    --query "taskDefinition.containerDefinitions[?name=='$SERVICE_NAME'].image | [0]" \
    --output text
)"

if [[ "$ACTIVE_IMAGE_URI" != "$IMAGE_URI" ]]; then
  die "Active Task Definition does not use the expected immutable image."
fi

echo
echo "Deployment completed successfully."
printf '%-21s %s\n' "Service:" "$ECS_SERVICE_NAME"
printf '%-21s %s\n' "Deployment:" "$DEPLOYMENT_ID"
printf '%-21s %s\n' "Source commit:" "$SOURCE_SHA"
printf '%-21s %s\n' "Image:" "$IMAGE_URI"
printf '%-21s %s\n' "Previous definition:" "$PREVIOUS_TASK_DEFINITION_ARN"
printf '%-21s %s\n' "Active definition:" "$NEW_TASK_DEFINITION_ARN"

if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
  {
    echo "## ECS deployment: $SERVICE_NAME"
    echo
    echo "- Deployment: \`$DEPLOYMENT_ID\`"
    echo "- Source commit: \`$SOURCE_SHA\`"
    echo "- Image: \`$IMAGE_URI\`"
    echo "- Previous Task Definition: \`$PREVIOUS_TASK_DEFINITION_ARN\`"
    echo "- Active Task Definition: \`$NEW_TASK_DEFINITION_ARN\`"
  } >>"$GITHUB_STEP_SUMMARY"
fi
