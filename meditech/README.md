# Meditech (Expanse) vendor profile

Profile for Meditech Expanse, targeting product version 2025.x.

## Supported inbound surfaces

- HL7 v2 MLLP on port 2575

## Supported message types

| Message type | StructureMap | Notes |
|---|---|---|
| `ADT^A04` | `maps/hl7v2-ADT-A04-Meditech.fml` | Patient registration |
| `ADT^A08` | `maps/hl7v2-ADT-A08-Meditech.fml` | Patient update |

## Quirks

| Quirk | Strategy |
|---|---|
| `msh3-format` | `standard` |
| `empty-pid-strategy` | `reject` |
| `attachment-encoding` | `base64-standard` |

## Audit

- `agent-system: meditech`
- Enrichments: PV1-7 → AuditEvent.agent.who, MSH-4 → AuditEvent.source.observer.identifier

## Known limitations

- Order + result message types (ORM, ORU) deferred to a follow-up version of this profile.
- Document references (MDM) out of scope.
