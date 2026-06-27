# Manifest reference

Every field in `manifest.yaml`, schema v1. The authoritative schema is `schemas/profile-manifest-v1.json`; this doc is the human-readable mirror.

## Top level

| Field | Type | Required | Description |
|---|---|---|---|
| `profile` | object | yes | Identity + versioning |
| `ingest` | array | yes | One or more inbound surfaces |
| `mappings` | array | yes | StructureMap bindings |
| `quirks` | object | no | Vendor-specific deviations |
| `audit` | object | no | AuditEvent enrichment rules |

## `profile`

| Field | Type | Required | Description |
|---|---|---|---|
| `id` | string | yes | Lower-case-kebab identifier, unique in the catalog |
| `version` | string | yes | SemVer for this profile bundle |
| `schemaVersion` | integer | yes | Manifest-schema version, currently always `1` |
| `vendor.name` | string | yes | Human-readable vendor name |
| `vendor.productLine` | string | yes | Product line within the vendor's portfolio |
| `vendor.productVersion` | string | yes | Target product version range |
| `fhirVersions` | array of string | yes | FHIR versions the mappings target. Almost always `[R4]` |
| `hl7Versions` | array of string | no | HL7 v2 versions the mappings accept. Omit if no v2 |

## `ingest[]`

Each entry creates one IngestSource bean in the engine.

| Field | Type | Required | Description |
|---|---|---|---|
| `id` | string | yes | Unique within this profile |
| `type` | string | yes | Plugin id: `hl7v2-mllp`, `fhir-r4-polling`, `athena-native-rest`, ... |
| `config` | object | yes | Type-specific config; see the plugin's README in the engine repo |

## `mappings[]`

Each entry binds one inbound message shape to a StructureMap.

| Field | Type | Required | Description |
|---|---|---|---|
| `messageType` | string | one of | For HL7 v2 sources: the message type (e.g., `ADT^A04`) |
| `sourceType` | string | one of | For non-v2 sources: a vendor-defined string (e.g., `athena-changed-patients`) |
| `map` | string | yes | Path to the `.fml` file, relative to the manifest |
| `tests` | array of string | no | Test fixture directories to exercise |

Exactly one of `messageType` or `sourceType` must be set.

## `quirks`

Key-value map. Each key names a quirk-strategy id known to the engine; each value names the specific strategy variant.

See `quirks-catalog.md` for the list of supported keys.

Unknown keys fail validation.

## `audit`

| Field | Type | Required | Description |
|---|---|---|---|
| `agent-system` | string | yes | Identifies the source vendor in audit reports |
| `enrichments` | array of object | no | Rules that copy fields from inbound messages into emitted AuditEvent resources |

See `audit-enrichments.md` for the supported rule shapes.

## Schema-version policy

`schemaVersion` is independent from `version`:

- Bumping `version` is normal — every profile change.
- Bumping `schemaVersion` is rare and coordinated with the engine. It happens when the manifest contract itself changes incompatibly.

The engine rejects profiles with a `schemaVersion` it doesn't understand. Upgrade the engine or downgrade the profile.
