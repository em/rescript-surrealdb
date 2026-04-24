# Versioning Contract

## Purpose

Binding packages version independently from the upstream SDK they bind, but the relationship between the two must be explicit, auditable, and codified.

## Peer Dependency Rule

The upstream SDK is always a peer dependency, never a regular dependency.

The peer dependency range in `package.json` defines the supported upstream version window. This range is the binding's public contract with consumers about which SDK versions the binding has been verified against.

## Version Pairing

The binding version and the upstream SDK version are independent semver sequences.

The binding's `peerDependencies` field is the sole source of truth for which upstream versions the binding supports. The binding does not mirror the upstream version number.

## What Constitutes a Breaking Change (Major Bump)

- Removing or renaming a public `.resi` export
- Changing a public type signature in a way that breaks existing consumer code
- Narrowing the peer dependency range to exclude a previously supported upstream version
- Changing the package entrypoint structure

## What Constitutes a New Feature (Minor Bump)

- Adding new public bindings for upstream surface that was previously unbound
- Widening the peer dependency range to include new upstream versions after verification
- Adding new package-authored API surface
- Tightening an `unknown` boundary to a precise type (this is additive, not breaking)

## What Constitutes a Fix (Patch Bump)

- Fixing a soundness issue without changing the public API shape
- Fixing incorrect nullish handling
- Fixing incorrect runtime classification
- Updating documentation and audit artifacts without code changes

## Upstream Version Changes

When the upstream SDK releases a new version:

1. Install the new version.
2. Diff the upstream `.d.ts` against the current binding `.resi` files.
3. Run the existing test suite against the new version.
4. Document any new, changed, or removed upstream surface.
5. Update the peer dependency range only after verification.
6. If the upstream change breaks existing bindings, fix the bindings and bump accordingly.

Do not widen the peer dependency range without running tests against the new version.

## Pre-Release Mode

This package is in changesets pre-release mode (`npx changeset pre enter alpha`). The `.changeset/pre.json` file controls this. While active, all versions produced by `changeset version` are `X.Y.Z-alpha.N` and published to the `alpha` dist-tag. `npm install rescript-surrealdb` will not resolve to alpha versions — consumers must explicitly `npm install rescript-surrealdb@alpha`.

The owner exits pre-release mode with `npx changeset pre exit` when the package is ready for stable release. The agent never exits pre-release mode on its own.

## Changeset Rule

Every user-facing package change requires a Changeset entry.

The Changeset type (major, minor, patch) must match the versioning rules above, not the subjective "size" of the change. A one-line soundness fix that changes a public type signature is a major bump. A hundred-line addition of new bindings is a minor bump.

Agents create changesets as part of normal binding work. The changeset type (major, minor, patch) must match the versioning rules above.

## Changelog

The changeset config `"changelog"` controls automatic CHANGELOG.md generation.

- `false` (current): changesets does not generate or write to CHANGELOG.md. The `.changeset/*.md` files are the changelog content. `changeset version` consumes them and bumps the version but writes nothing to CHANGELOG.md.
- `"@changesets/cli/changelog"` (default): changesets auto-generates CHANGELOG.md entries from changeset descriptions when `changeset version` runs. The agent does not write to CHANGELOG.md manually.
- `"@changesets/changelog-github"`: same as default but includes PR links and contributor names. Requires `GITHUB_TOKEN`.

The agent does not manually edit CHANGELOG.md. Either changesets generates it automatically (if configured), or it stays untouched.

## Publish Ownership

npm publication is owned by `.github/workflows/release.yml`. Only GitHub Actions has the npm credentials through trusted publishing with provenance.

- The workflow runs build and unit tests before the publish step. If either fails, nothing publishes.
- When pending changesets exist on main, the workflow runs `changeset version`, commits the version bump, tags the release, and publishes directly. No PRs are created.
- Local `npm publish`, `npm run release`, and `npm run version-packages` are forbidden. The agent never runs them outside GitHub Actions.

## Post-Publish Verification (MANDATORY)

After any push that includes changesets, the agent must verify the release pipeline completed correctly. Fire-and-forget is prohibited.

1. Check CI status: `gh run list --repo em/rescript-surrealdb -L 3`
2. If the Release workflow ran, verify it succeeded. If it failed, read the logs with `gh run view <id> --log-failed` and fix the cause.
3. After a successful publish, verify the npm registry reflects the new version: `npm view rescript-surrealdb version dist-tags --json`
4. Verify the GitHub Release was created with the correct tag: `gh release list --repo em/rescript-surrealdb -L 3`
5. If any step shows a mismatch between what was expected and what happened, investigate and fix before moving on.

The agent does not assume a push resulted in a publish. The agent checks.

## Auditability

The peer dependency range, the Changeset entries, the git tags created by the release workflow, and the commit history together form the auditable record of version decisions. A later maintainer must be able to trace why any version bump happened and what upstream version it was verified against.
