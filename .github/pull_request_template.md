## What this PR does

<one-paragraph summary>

## Type of change

- [ ] New vendor profile
- [ ] Update to an existing profile (new version, new mapping, new quirk)
- [ ] Bug fix
- [ ] Doc / typo

## Checklist

- [ ] Manifest validates against `schemas/profile-manifest-v1.json` (run `./scripts/validate.sh`)
- [ ] Test fixtures use only obviously-synthetic data (`MRN-EXAMPLE-001`, `Test Patient One`, DOB `1900-01-01`)
- [ ] No credentials, tokens, customer URLs, or real protected health data in any file
- [ ] Profile `version` bumped per SemVer if behavior changed
- [ ] Commits signed with DCO (`git commit -s`)
