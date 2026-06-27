# Epic vendor profile

Profile for Epic Systems' Epic EHR, targeting product version 2024.x.

## Supported inbound surfaces

- HL7 v2 MLLP on port 2575 (configurable via the engine's `subscription-service.ingest.hl7v2-mllp.port`)

## Supported message types

| Message type | StructureMap | Notes |
|---|---|---|
| `ADT^A04` | `maps/hl7v2-ADT-A04-Epic.fml` | Patient registration |
| `ORM^O01` | `maps/hl7v2-ORM-O01-Epic.fml` | Order |
| `ORU^R01` | `maps/hl7v2-ORU-R01-Epic.fml` | Observation result |

## Quirks applied

| Quirk | Strategy | What it handles |
|---|---|---|
| `msh3-format` | `facility-shortcode-then-pipe` | Epic emits MSH-3 as `<facility-shortcode>|<application>` rather than a single application identifier |
| `empty-pid-strategy` | `synthesize-from-mrn` | When PID is sparse, derive a minimal Patient identity from PID-3 |
| `attachment-encoding` | `base64-with-rtf-prefix-trim` | Strip Epic's RTF prefix from binary OBX-5 content before base64 decode |

## Audit enrichments

- `agent-system: epic` — stamps every emitted AuditEvent with an `epic` agent type
- `addOriginatingUser: pv1.7` — copies PV1-7 into AuditEvent.agent.who
- `addPatientFacility: msh.4` — copies MSH-4 into AuditEvent.source.observer.identifier

## Known limitations

- Maps target US Core R4 7.0.0 profiles. Customers on older US Core need a pinned-version build of the profile or a backport map.
- ORU mappings cover discrete numeric results. Narrative-only reports (image annotation, free-text impression sections) come through but downstream consumers may need a separate handler for them.
- Document references (MDM, CDA wrappers) are out of scope for this profile version — see `epic-documents` (future).

## Tests

Three scenarios under `tests/`, each with `input.hl7` + `expected.json`. Use only synthetic data — see CONTRIBUTING.md.
