# athenahealth (athenaOne) vendor profile

Profile for athenahealth athenaOne, targeting product version 21.x. Athena does NOT speak inbound HL7 v2 — this profile uses two REST-based ingest surfaces:

1. **Athena native REST API** (proprietary) — polling for changed patients, appointments, etc.
2. **Athena's FHIR R4 endpoint** — polling for observations and other resources Athena exposes via standard FHIR

## Required env vars

- `ATHENA_PRACTICE_ID` — the practice's numeric ID
- `ATHENA_DEPARTMENT_IDS` — comma-separated list of department IDs
- `ATHENA_CLIENT_ID` — OAuth2 client id
- `ATHENA_CLIENT_SECRET` — OAuth2 client secret (env-only; never commit)

## Supported source types

| Source type | StructureMap | Ingest |
|---|---|---|
| `athena-changed-patients` | `maps/athena-patient-normalize.fml` | Native REST poller |
| `fhir-r4-observation` | `maps/fhir-r4-observation-uscore-normalize.fml` | FHIR R4 poller |

## Quirks

| Quirk | Strategy |
|---|---|
| `athena-patient-id-namespace` | `practice-scoped` — Athena patient IDs are unique within a practice, not globally |
| `athena-encounter-departmentid-required` | `true` — Encounter resources must include department context |
| `fhir-observation-missing-category-strategy` | `derive-from-loinc` — Athena often omits Observation.category; derive from the LOINC code |

## Audit

- `agent-system: athena`
- Enrichments use the REST context not v2 fields: `query.practiceid`, `response-header.X-Audit-User`

## Known limitations

- Native-REST poller covers patients + appointments today. Document references and orders deferred.
- High-water-mark store is in-memory in the engine v1 — restart re-fetches recent rows; downstream idempotency absorbs the replay.
