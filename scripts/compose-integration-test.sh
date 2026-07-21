#!/usr/bin/env bash

set -Eeuo pipefail

export COMPOSE_PROJECT_NAME="${COMPOSE_PROJECT_NAME:-aws-voting-platform-integration}"
export DB_PASSWORD="${DB_PASSWORD:-integration-test-password}"
export OPTION_A="${OPTION_A:-Cats}"
export OPTION_B="${OPTION_B:-Dogs}"

cleanup() {
    exit_code=$?

    trap - EXIT

    if [ "$exit_code" -ne 0 ]; then
        echo
        echo "Integration test failed."
        echo "Container status:"
        docker compose ps --all || true

        echo
        echo "Container logs:"
        docker compose logs --no-color || true
    fi

    echo
    echo "Stopping integration environment..."

    docker compose down \
        --volumes \
        --remove-orphans \
        --timeout 10 \
        || true

    exit "$exit_code"
}

trap cleanup EXIT

echo "Docker version:"
docker version

echo
echo "Docker Compose version:"
docker compose version

echo
echo "Validating Docker Compose configuration..."
docker compose config --quiet

echo "Compose configuration is valid."

echo
echo "Building application images..."
docker compose build --pull

echo
echo "Starting integration environment..."

docker compose up \
    --detach \
    --wait \
    --wait-timeout 180

echo
echo "Container status:"
docker compose ps

echo
echo "Checking vote liveness..."
curl \
    --fail \
    --silent \
    --show-error \
    http://localhost:8080/health

echo
echo "Checking vote readiness..."
curl \
    --fail \
    --silent \
    --show-error \
    http://localhost:8080/ready

echo
echo "Checking result liveness..."
curl \
    --fail \
    --silent \
    --show-error \
    http://localhost:8081/health

echo
echo "Checking result readiness..."
curl \
    --fail \
    --silent \
    --show-error \
    http://localhost:8081/ready

echo
echo "Submitting integration test vote..."

curl \
    --fail \
    --silent \
    --show-error \
    --cookie-jar /tmp/vote-cookies.txt \
    --cookie /tmp/vote-cookies.txt \
    --request POST \
    --data "vote=a" \
    http://localhost:8080/ \
    > /dev/null

echo "Vote submitted."

echo
echo "Waiting for worker to persist the vote..."

vote_persisted=false

for attempt in $(seq 1 30); do
    vote_count="$(
        docker compose exec -T db sh -c \
            'psql \
                -U "$POSTGRES_USER" \
                -d "$POSTGRES_DB" \
                -tAc "SELECT COUNT(*) FROM votes;"' \
            | tr -d '[:space:]'
    )"

    echo "Attempt ${attempt}/30: database vote count=${vote_count:-0}"

    if [ "${vote_count:-0}" -ge 1 ]; then
        vote_persisted=true
        break
    fi

    sleep 2
done

if [ "$vote_persisted" != "true" ]; then
    echo "Worker did not persist the vote within 60 seconds."
    exit 1
fi

echo
echo "Checking stored vote..."

docker compose exec -T db sh -c \
    'psql \
        -U "$POSTGRES_USER" \
        -d "$POSTGRES_DB" \
        -c "SELECT id, vote FROM votes;"'

echo
echo "Checking result readiness after processing the vote..."

curl \
    --fail \
    --silent \
    --show-error \
    http://localhost:8081/ready

echo
echo "Checking worker health timestamp..."

docker compose exec -T worker sh -c '
    test -f /tmp/worker-health

    health_age=$(( $(date +%s) - $(cat /tmp/worker-health) ))

    echo "Worker health timestamp age: ${health_age} seconds"

    test "$health_age" -lt 30
'

echo
echo "Integration test completed successfully."
