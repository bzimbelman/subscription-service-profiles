# Audit enrichments

The `audit.enrichments` block in a manifest is a list of rules. Each rule is a one-key map: the key names a rule type, the value names a source field.

The engine's audit-event-fhir plugin reads these rules at request time and stamps the values onto every emitted `AuditEvent` FHIR resource.

## Shape

```yaml
audit:
  agent-system: <vendor-id>
  enrichments:
    - <rule-name>: <source-field>
    - <rule-name>: <source-field>
```

`agent-system` is a free-form string that identifies the vendor in audit reports. The engine puts it in `AuditEvent.agent.type`.

`enrichments` is an ordered list. Order matters when two rules target the same FHIR slot — the later rule wins.

## Source-field syntax

For HL7 v2 sources, the source field is named by HL7 structural address: `<segment>.<field>` (e.g., `pv1.7`, `msh.4`, `pid.3`). Sub-component access uses dots: `pv1.7.1.2`.

For FHIR / REST sources, the source field is a placeholder reference into the request context: `query.<param>`, `response-header.<name>`, `body.<jsonpath>`.

## Supported rule names

| Rule name | What it does | FHIR slot written |
|---|---|---|
| `addOriginatingUser` | Copy the source-field value into `AuditEvent.agent.who` as an actor reference | `agent[].who` |
| `addPatientFacility` | Copy the source-field value into `AuditEvent.source.observer.identifier` | `source.observer.identifier` |
| `addPracticeId` | Copy the source-field value into `AuditEvent.entity.what` for the practice context | `entity[].what` |
| `addAthenaUser` | Copy the source-field value into `AuditEvent.agent.who` from an Athena response header | `agent[].who` |

The list grows as the audit-event-fhir plugin ships new rules. Unknown rule names fail validation. See the [engine repo's audit plugin](https://github.com/bzimbelman/subscription-service/tree/main/plugins-builtin/audit-event-fhir) for the current set.

## Examples

HL7 v2 source:

```yaml
audit:
  agent-system: epic
  enrichments:
    - addOriginatingUser: pv1.7
    - addPatientFacility: msh.4
```

Non-v2 source (Athena native REST):

```yaml
audit:
  agent-system: athena
  enrichments:
    - addPracticeId: query.practiceid
    - addAthenaUser: response-header.X-Audit-User
```
