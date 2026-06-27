# Testing a profile

## v1 — manual

Until the test harness from ticket #446 lands, profiles are validated in two stages:

1. **Schema validation** — `./scripts/validate.sh` runs in CI and locally; checks the `manifest.yaml` against `schemas/profile-manifest-v1.json`.
2. **Manual scenario verification** — author runs their `tests/<scenario>/input.<ext>` fixtures through a local subscription-service deployment and confirms the engine emits the expected FHIR Bundles.

Reviewers spot-check at least one scenario per profile before approving.

## Manual verification recipe

```bash
# 1. Bring up subscription-service locally with your profile mounted
cd /path/to/subscription-service/deploy/docker
docker compose --env-file .env up -d
docker compose exec interface-engine mkdir -p /app/profiles/<vendor>
docker cp /path/to/subscription-service-profiles/<vendor>/. \
  subscription-service-interface-engine:/app/profiles/<vendor>/
docker compose restart interface-engine

# 2. Send an input through the relevant ingest port
# HL7 v2 via MLLP:
cat tests/<scenario>/input.hl7 | nc -q 1 localhost 2575

# 3. Fetch the resulting message + effects
curl -s -H "Authorization: Bearer $IPF_ADMIN_AUTH_TOKEN" \
  "http://localhost:18090/admin/messages?limit=10" | jq
curl -s -H "Authorization: Bearer $IPF_ADMIN_AUTH_TOKEN" \
  "http://localhost:18090/admin/messages/<id>/effects" | jq

# 4. Compare against tests/<scenario>/expected.json
```

## v2 — automated harness (ticket #446)

When #446 lands, this doc will document the automated runner. The runner will:

1. Stand up an ephemeral subscription-service stack via docker compose
2. Mount each profile's directory under `/app/profiles/`
3. Iterate every `tests/<scenario>/` under every profile
4. Send `input.<ext>` through the appropriate ingest port
5. Poll `/admin/messages/{id}/effects` until the message is processed
6. Compare the emitted FHIR Bundle against `expected.json`
7. Report pass/fail per scenario; fail the CI run if any scenario fails

Track progress at the engine repo's ticket #446.
