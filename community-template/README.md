# Vendor profile template

Copy this directory to `<your-vendor>/` (lower-case-kebab), then:

1. Edit `manifest.yaml` — replace every `<placeholder>` with a real value. See `../docs/manifest-reference.md`.
2. Drop FHIR Mapping Language (`.fml`) files under `maps/`.
3. Add input/expected test pairs under `tests/`. Each subdirectory holds one scenario.
4. Run `../scripts/validate.sh` to confirm your manifest parses against the schema.
5. Open a PR using the new-vendor template.

See `../CONTRIBUTING.md` for the contribution bar and `../docs/authoring-guide.md` for the walkthrough.
