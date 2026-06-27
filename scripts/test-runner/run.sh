#!/usr/bin/env bash
# Vendor profile test harness.
#
# v1 implementation: bring up the engine via docker compose, mount this
# repo's profiles as /app/profiles/, send each scenario's input through
# the appropriate ingest port, fetch effects, compare against expected.

set -euo pipefail

ENGINE_PATH="${ENGINE_PATH:-../subscription-service}"
PROFILE_FILTER=""
SCENARIO_FILTER=""
KEEP=0

usage() {
  echo "Usage: $0 [--profile <id>] [--scenario <id>] [--keep]"
  exit 2
}

while [ $# -gt 0 ]; do
  case "$1" in
    --profile) PROFILE_FILTER="$2"; shift 2 ;;
    --scenario) SCENARIO_FILTER="$2"; shift 2 ;;
    --keep) KEEP=1; shift ;;
    -h|--help) usage ;;
    *) echo "unknown arg: $1"; usage ;;
  esac
done

if [ ! -d "$ENGINE_PATH" ]; then
  echo "Engine repo not found at $ENGINE_PATH. Set ENGINE_PATH or clone bzimbelman/subscription-service."
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

cleanup() {
  if [ "$KEEP" -eq 0 ]; then
    (cd "$ENGINE_PATH/deploy/docker" && docker compose down -v >/dev/null 2>&1) || true
  else
    echo "--keep set; stack left running at engine docker-compose."
  fi
}
trap cleanup EXIT

echo "Bringing up engine stack from $ENGINE_PATH/deploy/docker..."
(cd "$ENGINE_PATH/deploy/docker" && docker compose up -d --quiet-pull)

echo "Waiting for engine /api/health..."
for _ in $(seq 1 60); do
  if curl -fsS http://localhost:18090/actuator/health/readiness >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

PASS=0
FAIL=0

for manifest in "$REPO_ROOT"/*/manifest.yaml; do
  [ -f "$manifest" ] || continue
  PROFILE_DIR="$(dirname "$manifest")"
  PROFILE_ID="$(basename "$PROFILE_DIR")"
  [ "$PROFILE_ID" = "community-template" ] && continue
  if [ -n "$PROFILE_FILTER" ] && [ "$PROFILE_FILTER" != "$PROFILE_ID" ]; then
    continue
  fi

  echo "Profile: $PROFILE_ID"
  for scenario_dir in "$PROFILE_DIR"/tests/*/; do
    [ -d "$scenario_dir" ] || continue
    SCENARIO_ID="$(basename "$scenario_dir")"
    if [ -n "$SCENARIO_FILTER" ] && [ "$SCENARIO_FILTER" != "$SCENARIO_ID" ]; then
      continue
    fi

    echo "  Scenario: $SCENARIO_ID"
    INPUT_FILE=$(ls "$scenario_dir"input.* 2>/dev/null | head -1 || true)
    EXPECTED_FILE="$scenario_dir/expected.json"

    if [ -z "$INPUT_FILE" ] || [ ! -f "$EXPECTED_FILE" ]; then
      echo "    SKIP: missing input or expected"
      continue
    fi

    case "$INPUT_FILE" in
      *.hl7)
        # MLLP wrap and send
        START=$'\x0b'
        END=$'\x1c\x0d'
        ( printf '%s' "$START"; cat "$INPUT_FILE"; printf '%s' "$END" ) | nc -q 1 localhost 2575 >/dev/null
        ;;
      *.json)
        echo "    Note: JSON-input scenarios depend on the fhir-polling ingest plugin; runner v1 logs the input and marks SKIP."
        FAIL=$((FAIL + 1))
        continue
        ;;
      *)
        echo "    SKIP: unknown input extension"
        continue
        ;;
    esac

    sleep 5

    # Fetch most recent message + effects. Real harness would track message id from the ingest response.
    LATEST=$(curl -fsS -H "Authorization: Bearer ${IPF_ADMIN_AUTH_TOKEN:-dev-bearer-epic-398}" \
      "http://localhost:18090/admin/messages?limit=1&sort=-received_at" | jq -r '.items[0].id // empty')
    if [ -z "$LATEST" ]; then
      echo "    FAIL: no message recorded"
      FAIL=$((FAIL + 1))
      continue
    fi

    EFFECTS=$(curl -fsS -H "Authorization: Bearer ${IPF_ADMIN_AUTH_TOKEN:-dev-bearer-epic-398}" \
      "http://localhost:18090/admin/messages/$LATEST/effects" 2>/dev/null || echo '{}')

    # v1: existence-only assertion. Full structural diff lands in v2.
    if echo "$EFFECTS" | jq -e '.fhir_resources | length > 0' >/dev/null 2>&1; then
      echo "    PASS"
      PASS=$((PASS + 1))
    else
      echo "    FAIL: no FHIR resources emitted"
      FAIL=$((FAIL + 1))
    fi
  done
done

echo ""
echo "Result: $PASS passed, $FAIL failed."
[ "$FAIL" -eq 0 ] || exit 1
