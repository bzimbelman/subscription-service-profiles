# Publishing a profile

After a profile lands on main, a maintainer tags + releases it. End-users download release tarballs rather than tracking the git repo.

## Release flow

```bash
# From main, after the PR merges
git pull
git tag <vendor>-v<semver>           # e.g., epic-v2024.1.0
git push origin <vendor>-v<semver>
```

The `release.yml` workflow:

1. Parses `<vendor>` and `<semver>` from the tag
2. Verifies the `<vendor>/` directory exists at the tagged commit
3. Bundles `<vendor>/` into `<vendor>-v<semver>.tgz`
4. Creates a GitHub Release with auto-generated notes from PR titles since the previous release tag for that vendor

The release page is the public artifact. Customers install by downloading the tarball and untarring under their engine's `/app/profiles/`.

## Versioning rules

Per-vendor SemVer, independent across vendors:

- **MAJOR** — breaking map output: a customer's downstream code may need to change
- **MINOR** — backward-compatible: new message type, new quirk, new tests
- **PATCH** — backward-compatible fix: corrected enum, typo in a map

Examples:

- `epic-v2024.1.0` — initial Epic profile
- `epic-v2024.1.1` — fixed a wrong identifier system in the ADT map
- `epic-v2024.2.0` — added ORM^O01 support
- `epic-v2025.1.0` — new map output shape for the new Epic version
- `athena-v2026-Q2.0` — first Athena profile

## Cosign signing (future)

The release workflow has a TODO marker for cosign signing. When it lands:

1. Each release tarball gets a `.sig` and `.crt` attached
2. Consumers verify with `cosign verify-blob --certificate ...`
3. The engine's profile loader can be configured to require signatures before loading

This is on the roadmap; not yet enforced. Plain tarballs are accepted today.

## Yanking a release

If a release has a security issue or correctness bug too severe to live with:

1. Delete the release on GitHub (this hides the tarball download)
2. DO NOT delete the tag — that breaks anyone who pinned to it
3. Tag the fix as a PATCH or MAJOR depending on severity
4. Edit the release's body to point users at the new release

## Pre-release tags

For staged rollout:

```bash
git tag epic-v2025.0.0-rc.1
git push origin epic-v2025.0.0-rc.1
```

The workflow detects the `-rc.N` suffix and marks the GitHub Release as a pre-release. Pre-release tarballs are visible but not surfaced as "Latest."
