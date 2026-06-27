# subscription-service-profiles

Vendor profiles for [subscription-service](https://github.com/bzimbelman/subscription-service) — declarative YAML manifests + FHIR StructureMaps that teach the pipeline how a specific EHR (Epic, Meditech, Cerner, Athena, NextGen, ...) speaks HL7 v2 and FHIR.

License: Apache 2.0.

## What this repo IS

A **catalog of vendor profiles**. Each top-level directory (when stories #441-#445 land) is one vendor profile: a `manifest.yaml`, a `maps/` directory of FHIR Mapping Language (FML) StructureMaps, and a `tests/` directory of input/expected pairs.

A profile is a fully declarative description of how subscription-service should ingest data from one vendor and convert it to canonical FHIR R4. It does NOT contain executable code. The interface engine in subscription-service reads the manifest at startup, loads the maps Matchbox runs, and applies the declared quirks + audit enrichments.

The repo holds:

- `schemas/profile-manifest-v1.json` — the JSON Schema every manifest is validated against. This is a mirror of the canonical schema that ships inside subscription-service's `profile-loader` plugin.
- `community-template/` — a working skeleton a contributor copies to start a new profile.
- `docs/` — authoring guide, manifest reference, quirks catalog, audit-enrichments reference, testing-a-profile guide.
- `.github/workflows/ci.yml` — validates every manifest against the schema on every PR.
- `.github/workflows/release.yml` — tags + bundles a profile version into a release tarball.

## What this repo is NOT

- It is NOT the engine. Pipeline code lives in [bzimbelman/subscription-service](https://github.com/bzimbelman/subscription-service).
- It is NOT a marketplace. There's no payment, no install button, no remote registry. To consume a profile you `git clone` (or download a release tarball) and mount the directory into your subscription-service deployment.
- It is NOT where vendor-certified profiles live. The Pro-tier certified profiles ship in a separate commercial repo (see [master plan §3.1](https://github.com/bzimbelman/subscription-service)). The community-quality profiles for the top EHRs live here, are Apache 2.0, and stay free forever.

## How profiles work

Every profile contains a `manifest.yaml` like:

```yaml
profile:
  id: epic
  version: "2024.1"
  schemaVersion: 1
  vendor:
    name: Epic Systems
    productLine: Epic
    productVersion: "2024.x"
  fhirVersions: [R4]
  hl7Versions: [v2.5, v2.5.1, v2.7]

ingest:
  - id: mllp-default
    type: hl7v2-mllp
    config:
      port: 2575
      facilityResolver: epic-msh-3-facility

mappings:
  - messageType: ADT^A04
    map: maps/hl7v2-ADT-A04-Epic.fml
    tests: [tests/adt-a04/]

quirks:
  msh3-format: facility-shortcode-then-pipe
  empty-pid-strategy: synthesize-from-mrn

audit:
  agent-system: epic
  enrichments:
    - addOriginatingUser: pv1.7
    - addPatientFacility: msh.4
```

Four blocks, each pluggable:

- **`profile`** — identity + versioning. The `schemaVersion` is what the loader checks for compatibility; the `version` is for humans.
- **`ingest`** — one or more ingest sources. `type` names a plugin (`hl7v2-mllp`, `athena-native-rest`, `fhir-r4-polling`, ...). Profiles can have ZERO HL7 if the vendor is REST-only (see Athena example).
- **`mappings`** — for each inbound message shape, the StructureMap to apply. Either `messageType` (HL7 v2) or `sourceType` (FHIR / REST) keys the rule.
- **`quirks`** — vendor-specific deviations from the standard, evaluated at parse / pre-map time. Each key must be a known quirk-strategy id; the loader fails with a clear error if a profile asks for a quirk this engine version doesn't implement.
- **`audit`** — controls what gets stamped onto emitted `AuditEvent` resources. `agent-system` identifies the source vendor in audit reports; `enrichments` copy v2 fields (or REST context) into FHIR audit slots.

See [docs/authoring-guide.md](docs/authoring-guide.md) for an end-to-end walkthrough.

## How to consume a profile

Two options:

**1. Mount the directory into your deployment.**

```bash
git clone https://github.com/bzimbelman/subscription-service-profiles
docker run \
  -v "$PWD/subscription-service-profiles/epic:/profiles/epic" \
  -e PROFILE_DIR=/profiles/epic \
  ghcr.io/bzimbelman/subscription-service:latest
```

**2. Pull a release tarball.**

Each profile is released independently with a tag like `epic-v2024.1.0`. Download from the [Releases page](https://github.com/bzimbelman/subscription-service-profiles/releases), untar into the engine's profile directory, restart.

## How to contribute

See [CONTRIBUTING.md](CONTRIBUTING.md). The short version:

1. Copy `community-template/` to `<your-vendor>/`.
2. Fill in `manifest.yaml`, drop StructureMaps under `maps/`, add input/expected test pairs under `tests/`.
3. Run `./scripts/validate.sh` to confirm the manifest parses against the schema.
4. Open a PR. CI validates the manifest; reviewers exercise the test fixtures with the harness from [bzimbelman/subscription-service](https://github.com/bzimbelman/subscription-service) (see [ticket #446](https://github.com/bzimbelman/subscription-service-profiles/issues)).

## Repository status

This is the foundational scaffold (OpenProject ticket #440). Vendor profiles arrive in subsequent stories:

- #441 — Epic profile
- #442 — Meditech profile
- #443 — Cerner profile
- #444 — Athena profile
- #445 — NextGen profile
- #446 — Test harness (round-trips every profile's `tests/` fixtures through the engine in CI)

## Related links

- Engine: <https://github.com/bzimbelman/subscription-service>
- Master plan: see `subscription-service-master-plan.md` in the engine repo, §3.1 + §4.3
- Issue tracker: GitHub Issues on this repo
- Community discussion: GitHub Discussions on the engine repo
