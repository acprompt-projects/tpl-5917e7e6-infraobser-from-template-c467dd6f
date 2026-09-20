#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Ensuring observability network exists..."
docker network inspect observability >/dev/null 2>&1 || docker network create observability

echo "==> Deploying Loki + Promtail..."
docker compose -f "$SCRIPT_DIR/docker-compose.yml" up -d

echo "==> Waiting for Loki to become healthy..."
for i in $(seq 1 30); do
  if curl -sf http://localhost:3100/ready >/dev/null 2>&1; then
    echo "==> Loki is ready at http://localhost:3100"
    exit 0
  fi
  sleep 2
done

echo "ERROR: Loki did not become ready within 60s" >&2
exit 1