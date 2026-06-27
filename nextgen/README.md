# NextGen Healthcare (Enterprise) vendor profile

Profile for NextGen Healthcare's Enterprise EHR, targeting product version 2025.x.

## Supported inbound surfaces

- HL7 v2 MLLP on port 2575

## Supported message types

| Message type | StructureMap |
|---|---|
| `ADT^A04` | `maps/hl7v2-ADT-A04-NextGen.fml` |

## Quirks

| Quirk | Strategy |
|---|---|
| `msh3-format` | `standard` |
| `empty-pid-strategy` | `reject` |
| `attachment-encoding` | `base64-standard` |

## Audit

- `agent-system: nextgen`
- Enrichments: PV1-7, MSH-4

## Known limitations

- Initial profile version covers only ADT^A04. ORM/ORU/MDM message types deferred to follow-up versions.
