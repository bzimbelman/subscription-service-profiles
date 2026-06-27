# Quirks catalog

Quirks are named strategies the engine applies at parse / pre-map time to handle vendor-specific deviations from the standard. Each `quirks` entry in a manifest references a strategy by id; the engine runs the strategy before the mapping rules see the message.

This catalog lists the strategies known to the engine's current built-in plugins. New strategies land in the engine repo; PRs to add a strategy here without a corresponding engine implementation are rejected.

## `msh3-format`

How to interpret the MSH-3 (Sending Application) field on inbound HL7 v2 messages.

| Value | Behavior |
|---|---|
| `standard` | Treat MSH-3 as a single application identifier |
| `facility-shortcode-then-pipe` | MSH-3 contains `<shortcode>|<application>`; split on `|` and treat the shortcode as the facility, the rest as the application |

## `empty-pid-strategy`

What to do when the PID segment is missing or empty.

| Value | Behavior |
|---|---|
| `reject` | Fail the message |
| `synthesize-from-mrn` | Build a minimal Patient resource using only the MRN from PID-3 |

## `attachment-encoding`

How attachments (OBX-5 binary content, MDM blobs) are encoded by the vendor.

| Value | Behavior |
|---|---|
| `base64-standard` | Standard base64; pass through |
| `base64-with-rtf-prefix-trim` | The vendor wraps base64 in an RTF prefix; strip the prefix before decoding |

## Adding a new strategy

Propose new quirk strategies in the [engine repo](https://github.com/bzimbelman/subscription-service). The strategy lands as code in `plugins-builtin/` first; this catalog updates to document the new id.
