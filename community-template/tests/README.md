# tests/

One subdirectory per scenario, each containing:

- `input.<ext>` — the inbound message (`.hl7` for HL7 v2, `.json` for FHIR, etc.)
- `expected.json` — the FHIR Bundle the engine should emit after running the mapping

The test harness (ticket #446) round-trips every `input` through the engine and asserts the output equals `expected`. Until #446 lands, the harness is a stub and reviewers verify scenarios manually.

Use only obviously-synthetic data. Identifiers like `MRN-EXAMPLE-001`, names like `Test Patient One`, dates of birth like `1900-01-01`. Anything that looks like real protected health data will be rejected at review.
