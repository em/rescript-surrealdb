# Release Publish Path Audit

## Claim

- subsystem: release process
- change: harden the repository so npm publication only happens through GitHub Actions trusted publishing
- boundary class: maintainer workflow and release ownership
- exact public surface affected:
  - `package.json`
  - `.github/workflows/release.yml`
  - `.changeset/README.md`
  - `README.md`
  - `docs/process/BINDING_PROOF_PROCESS.md`
  - `docs/process/VERSIONING_CONTRACT.md`
  - `docs/process/README_CONTRACT.md`

## Upstream Evidence

### Declaration Evidence

- file: `.github/workflows/release.yml`
  - relevant signature: the repo already grants `id-token: write` and uses `changesets/action`, which is the trusted-publishing path.

### Runtime Evidence

- command or probe:
  - `npm run release`
  - `node ./scripts/releasePublish.mjs`
- result:
  - local `npm run release` now refuses with an explicit GitHub Actions-only message
  - local `releasePublish.mjs` refuses without GitHub Actions trusted publishing environment variables

## Local Representation

- affected files:
  - `package.json`
  - `.github/workflows/release.yml`
  - `.changeset/README.md`
  - `README.md`
  - `docs/process/BINDING_PROOF_PROCESS.md`
  - `docs/process/VERSIONING_CONTRACT.md`
  - `docs/process/README_CONTRACT.md`
  - `scripts/releaseLocalRefusal.mjs`
  - `scripts/releasePublish.mjs`
- chosen shape:
  - `npm run release` is a hard local refusal
  - `npm run release:ci` is the only publish command and checks for GitHub Actions trusted publishing environment
  - docs now state that local shells do not publish

## Alternatives Considered

### Alternative 1

- representation: keep `npm run release` as a raw `npm publish --provenance`
- why rejected: it implies that local publication is valid and invites the exact workflow mistake this audit is correcting.

### Alternative 2

- representation: rely on README wording alone
- why rejected: the foot-gun remains in `package.json`, where maintainers and automation look first.

## Adversarial Questions

- question: does this break the existing release workflow
- evidence-based answer: no. The workflow now calls `npm run release:ci`, which performs the same publish command but only inside GitHub Actions.

- question: why not let local maintainers publish as a fallback
- evidence-based answer: this repo already uses trusted publishing through GitHub Actions. A local fallback is a misleading parallel path, not a requirement.

- question: could someone still bypass the guard with a raw manual command
- evidence-based answer: yes, but the repository process and first-class scripts now stop endorsing that path and make misuse obvious.

## Failure Modes Targeted

- failure mode: maintainers mistake a local shell for the release authority
- how the current design prevents or exposes it: `npm run release` fails immediately with an explicit message
- test or probe covering it: `npm run release`

- failure mode: workflow and docs drift apart about who publishes
- how the current design prevents or exposes it: README, Changesets README, process docs, package scripts, and workflow now all describe the same GitHub Actions-only path
- test or probe covering it: file inspection

## Evidence

### Build

- command: `npm run build`
- result: passed after script and documentation changes

### Tests

- command: `npm run release`
- result: failed intentionally with the local-refusal message

### Soundness Matrix Update

- affected row: none
- update made: not applicable; this audit hardens repo process rather than binding surface

## Residual Risk

- remaining open boundary: a maintainer can still run raw `npm publish` manually outside the scripted path
- why it remains open: repository documentation and scripts can forbid and discourage the path, but they cannot physically remove npm from a maintainer shell
- where it is documented: `README.md`, `.changeset/README.md`, `docs/process/VERSIONING_CONTRACT.md`

## Verdict

- status:
  - acceptable with documented fidelity gap
- reviewer: Codex
- date: 2026-04-22
