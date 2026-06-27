# Oracle Health (Cerner Millennium) vendor profile

Profile for Oracle Health's Cerner Millennium, targeting product version 2025.x.

## Supported inbound surfaces

- HL7 v2 MLLP on port 2575

## Supported message types

| Message type | StructureMap |
|---|---|
| `ADT^A04` | `maps/hl7v2-ADT-A04-Cerner.fml` |
| `ORU^R01` | `maps/hl7v2-ORU-R01-Cerner.fml` |

## Quirks

| Quirk | Strategy |
|---|---|
| `msh3-format` | `standard` |
| `empty-pid-strategy` | `reject` |
| `attachment-encoding` | `base64-standard` |

## Audit

- `agent-system: cerner`
- Enrichments: PV1-7, MSH-4

## Known limitations

- Order types (ORM) deferred.
- FHIR Bulk Data ingestion (Cerner's preferred path for many integrations) is a separate ingest plugin in the engine — when it lands, a future profile version will add a `fhir-bulk` ingest entry.
