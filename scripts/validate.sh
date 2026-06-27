#!/usr/bin/env bash
# Validate every manifest.yaml in the repo against the JSON Schema.
#
# Skips community-template/ because the template's manifest intentionally
# contains <placeholder> values that don't validate.
#
# Used by .github/workflows/ci.yml on every PR + push to main.

set -euo pipefail

SCHEMA="schemas/profile-manifest-v1.json"
EXIT=0
COUNT=0

if ! command -v ajv >/dev/null 2>&1; then
  echo "ajv-cli not found on PATH. Install with: npm install -g ajv-cli@5 ajv-formats@3"
  exit 2
fi

while IFS= read -r manifest; do
  echo "Validating $manifest..."
  if ! ajv validate -s "$SCHEMA" -d "$manifest" --strict=false; then
    EXIT=1
  fi
  COUNT=$((COUNT + 1))
done < <(find . \
  -path ./community-template -prune -o \
  -path ./.git -prune -o \
  -name 'manifest.yaml' -type f -print)

if [ "$COUNT" -eq 0 ]; then
  echo "No manifests found (community-template is excluded by design)."
  echo "Add a vendor directory with manifest.yaml to exercise this script."
elif [ "$EXIT" -eq 0 ]; then
  echo "All $COUNT manifests valid."
fi
exit "$EXIT"
