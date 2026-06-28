# Contributing to subscription-service-profiles

Thanks for considering a contribution. This repo is a catalog of vendor profiles for [subscription-service](https://github.com/bzimbelman/subscription-service). A "vendor profile" is a declarative bundle — YAML manifest, FHIR Mapping Language (FML) StructureMaps, sample messages — that teaches the pipeline how a specific EHR speaks.

## Ground rules — the security bar

**A profile MUST NOT execute arbitrary code.** Profiles are loaded into customers' production deployments. We are highly conservative about what we accept.

Specifically:

- Profiles contain only:
  - A `manifest.yaml` conforming to `schemas/profile-manifest-v1.json`
  - FML StructureMap files (`*.fml`) — declarative mapping rules processed by Matchbox
  - Test fixtures (HL7 v2 messages, FHIR JSON, expected outputs) under `tests/`
  - A `README.md` documenting the profile, its supported EHR versions, and known limitations
- Profiles MUST NOT contain:
  - JavaScript, Python, shell scripts, JAR files, native binaries — nothing executable
  - HTTP calls baked into manifests, side effects, "post-install" hooks
  - Credentials, API keys, tokens, customer-specific URLs, or PHI in test fixtures
  - Patient-identifying data of any kind in fixtures, even synthetic-looking. Use clearly fake names ("Test Patient One"), out-of-range birthdates, and obviously-synthetic identifiers (`MRN-EXAMPLE-001`).
- A profile that needs behavior the manifest schema doesn't express MUST first propose a new quirk strategy or ingest plugin in the [engine repo](https://github.com/bzimbelman/subscription-service) — and have it land there — before the profile PR is accepted here. We do not invent new contract surface inside the profiles repo.

**We reserve the right to reject any contribution at our discretion.** Common rejection reasons: scope creep, security concerns, missing tests, fixtures with real PHI, profiles that try to extend the manifest contract by stuffing unknown fields in `additionalProperties`.

## What we accept

| Kind of PR | Bar |
|---|---|
| **New vendor profile** | Manifest validates, has at least one StructureMap + matching test fixture pair, includes a `README.md` documenting the EHR versions supported and known limitations. The five "anchor" vendors (Epic, Meditech, Cerner, Athena, NextGen) are seeded by us in stories #441-#445; PRs for additional vendors are welcome after those land. |
| **Update to an existing profile** (e.g., a new EHR version) | Bumps `profile.version`, adds new tests for any new mapping rules, leaves existing tests passing. |
| **Bug fix** | Adds a regression test fixture in `tests/` that fails before the fix and passes after. |
| **Doc / typo** | Open the PR; CI will tell us. |
| **New quirk strategy** | NOT accepted here — propose it in the [engine repo](https://github.com/bzimbelman/subscription-service) first. |
| **New ingest plugin** | NOT accepted here — propose it in the engine repo first. |

## Workflow

1. **Fork** the repo, clone, create a branch.
2. **Copy the template:** `cp -r community-template/ <your-vendor>/` and start editing.
3. **Author your manifest** following [docs/authoring-guide.md](docs/authoring-guide.md) and [docs/manifest-reference.md](docs/manifest-reference.md).
4. **Drop your maps** under `<your-vendor>/maps/` and your fixtures under `<your-vendor>/tests/`.
5. **Validate locally:**
   ```bash
   ./scripts/validate.sh
   ```
   This runs the JSON-Schema validator against every `manifest.yaml` in the repo. CI does the same check.
6. **Run the test harness** (when it lands — see [ticket #446](#)) to round-trip every fixture through the engine. Until then, manual verification against a local subscription-service deployment is acceptable for new profile PRs.
7. **Open a PR** using the appropriate template (bug / new-vendor / update).
8. **Review:** at least one maintainer reviews. We may ask for changes; we may say no. We will always tell you why.
9. **Merge:** maintainers merge after CI is green and review is approved.

## Versioning

Each vendor profile is independently versioned with semantic versioning:

- **MAJOR** (`epic-v3.0.0`): breaking changes — a map output shape change that requires consumers to update their downstream code or re-validate.
- **MINOR** (`epic-v2.1.0`): backward-compatible — new mappings, new quirks, new tests.
- **PATCH** (`epic-v2.0.1`): backward-compatible fixes — a typo in a map, a corrected enum value.

The `profile.version` field in `manifest.yaml` is the SemVer for THAT profile. The `profile.schemaVersion` field is the manifest-schema version (currently always `1`); it only changes when the schema itself changes incompatibly, which is a coordinated change with the engine repo.

## Releases & signing

Tagging a release creates a tarball of just the vendor's directory:

```bash
git tag epic-v2024.1.0
git push origin epic-v2024.1.0
```

The `release.yml` workflow attaches `epic-v2024.1.0.tgz` to a GitHub Release.

**Signing (TODO):** future releases will be signed with [cosign](https://docs.sigstore.dev/cosign/overview/). Consumers will be able to verify the signature before loading a profile. This is not yet implemented; PRs to add it are welcome.

## Commit messages & sign-off

We use the **Developer Certificate of Origin (DCO)** — sign every commit:

```bash
git commit -s -m "epic: add ORM^O01 mapping for med-administration order type"
```

No CLA. The Apache 2.0 + DCO combination keeps things simple and contributor-friendly.

Commit message format: `<vendor>: <short subject>` (lower-case subject, imperative mood). The body explains *why*.

## Code of conduct

By participating in this project you agree to follow the [Code of Conduct](CODE_OF_CONDUCT.md) (Contributor Covenant v2.1). The maintainer enforces it.

## Governance

See [GOVERNANCE.md](GOVERNANCE.md) for the maintainership model and how decisions get made. Today the project has a single maintainer; a steering committee is planned once sustained external contribution arrives.

## Reporting security issues

See [SECURITY.md](SECURITY.md). **Do not file a public GitHub issue** for a profile that mishandles PHI, leaks credentials, or otherwise has security implications. Email the maintainers instead.

## Questions

Open a [GitHub Discussion](https://github.com/bzimbelman/subscription-service/discussions) on the engine repo. We use one Discussions instance for the whole project so you don't have to guess where to ask.
