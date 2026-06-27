# Authoring a vendor profile

End-to-end recipe for contributing a new profile. Estimated time: a few hours for a simple HL7-v2 profile, more for one with non-standard ingest or many message types.

## Prerequisites

- A working local subscription-service deployment. Follow the [engine repo's quickstart](https://github.com/bzimbelman/subscription-service#quickstart).
- The vendor's interface specification (conformance statement, integration guide, etc.) so you can build accurate mappings.
- Sample inbound messages from a non-production environment. Strip every piece of real protected health data before bringing the messages into this repo.
- `git`, `node` (for `ajv-cli`), and a text editor.

## Step 1 — Copy the template

```bash
git clone https://github.com/bzimbelman/subscription-service-profiles
cd subscription-service-profiles
cp -r community-template/ <your-vendor>/
```

`<your-vendor>` should be a lower-case-kebab id: `epic`, `meditech`, `cerner`, `athena`, `nextgen`, `oracle-health`, etc.

## Step 2 — Fill in the manifest

Open `<your-vendor>/manifest.yaml` and replace every `<placeholder>` with a real value. See `manifest-reference.md` for the field-by-field reference.

Most fields are straightforward. The ones that take thinking:

- **`ingest`** — one entry per inbound surface. A vendor that supports both HL7 v2 MLLP and FHIR polling gets two entries (one of `type: hl7v2-mllp`, one of `type: fhir-r4-polling`). The `config` block is type-specific; see the engine's plugin READMEs.
- **`quirks`** — only use known quirk-strategy ids. See `quirks-catalog.md`. If your vendor needs a quirk that isn't in the catalog, file an issue on the engine repo to propose adding it; the profile PR depends on the engine PR landing first.
- **`audit.enrichments`** — see `audit-enrichments.md`.

## Step 3 — Author your StructureMaps

Drop FHIR Mapping Language files under `<your-vendor>/maps/`. Conventional naming:

- HL7 v2: `hl7v2-<message-type>-<vendor>.fml` (e.g., `hl7v2-ADT-A04-Epic.fml`)
- Non-v2: `<source-type>-<vendor>.fml`

The maps are run by Matchbox via the engine's `$transform` operation. Test them with Matchbox directly during development:

```bash
curl -X POST http://localhost:18081/matchboxv3/fhir/StructureMap/$transform \
  -H "Content-Type: application/json" \
  --data-binary @sample-input.json
```

## Step 4 — Add test fixtures

Under `<your-vendor>/tests/`, create one subdirectory per scenario:

```
<your-vendor>/tests/
  adt-a04-basic/
    input.hl7
    expected.json
  adt-a04-with-attachment/
    input.hl7
    expected.json
```

Synthetic data only. Use identifiers like `MRN-EXAMPLE-001`, names like `Test Patient One`, and dates of birth like `1900-01-01`. The reviewer will reject anything that looks like real data.

Reference each test directory from the corresponding `mappings[].tests` entry in `manifest.yaml`.

## Step 5 — Validate locally

```bash
./scripts/validate.sh
```

This runs `ajv` against every `manifest.yaml` in the repo (excluding `community-template/`). If your manifest fails, the error names the path + the violation; fix and re-run.

When the test harness from ticket #446 lands, you'll also be able to round-trip your test fixtures through the engine before opening the PR. Until then, exercise them manually against a local subscription-service deployment.

## Step 6 — Open a PR

```bash
git checkout -b <your-vendor>-initial
git add <your-vendor>/
git commit -s -m "<your-vendor>: initial profile"
git push origin <your-vendor>-initial
gh pr create --template=new-vendor.md
```

The `-s` flag signs the commit per the DCO requirement.

## Step 7 — Review

At least one maintainer reviews. We may ask for changes; we may say no. We will always tell you why.

Common review comments:

- "Your test fixture contains realistic-looking data — switch to `MRN-EXAMPLE-001` style."
- "Your manifest references an unknown quirk strategy — propose it in the engine repo first."
- "Your map's output doesn't include the US Core profile slices we expect for that resource."

## Step 8 — Release

After merge, a maintainer tags `<your-vendor>-v<semver>` (e.g., `epic-v2024.1.0`). The release workflow bundles the directory and attaches a tarball to a GitHub Release.

Subsequent updates to the profile follow the same flow — copy + edit + validate + PR. Bump `version` in the manifest per SemVer.
