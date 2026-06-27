# test-runner

End-to-end test harness for vendor profiles. Brings up a docker-compose subscription-service stack with the catalog mounted under `/app/profiles/`, sends every `tests/<scenario>/input.<ext>` through the appropriate ingest port, polls `/admin/messages/{id}/effects`, and compares the emitted FHIR Bundle against `expected.json`.

Used by CI on every PR and locally before opening a PR.

## Usage

```bash
# Run every profile's tests against an ephemeral stack
./run.sh

# Run a single profile
./run.sh --profile epic

# Run a single scenario
./run.sh --profile epic --scenario adt-a04-basic

# Keep the stack up after the run for manual debugging
./run.sh --keep
```

## Requirements

- Docker + docker compose v2
- `jq`, `nc` (BSD or GNU), `curl`
- A clone of [bzimbelman/subscription-service](https://github.com/bzimbelman/subscription-service) at `$ENGINE_PATH` (default: `../subscription-service`)

## Comparison semantics

`expected.json` is compared structurally against the engine's emitted Bundle, with these rules:

- `<placeholder-uuid>` values in expected match any UUID-shaped string in actual
- Timestamps with explicit placeholder values match any ISO-8601 string
- Field order is irrelevant (JSON object comparison)
- Extra fields in actual are tolerated unless `expected.json` has `"_strict": true` at the top level

Mismatches print a diff and fail the scenario.
