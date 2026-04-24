# Binding Proof Process

## Purpose

This repository does not trust a binding author, human or agent, to "just get it right".

Every non-trivial public binding change must produce a reproducible chain of evidence, survive adversarial review, and leave behind durable artifacts that a later maintainer can inspect without relying on trust or memory.

## Applies To

Run this process for any change that does one or more of these:

- changes a public `.resi`
- adds or changes `unknown`, `%identity`, `Obj.magic`, `%raw`, `@unboxed`, `@tag`, or `*Raw`
- changes a public generic, nullish boundary, error surface, or runtime class binding
- changes helper-vs-upstream surface classification
- changes supported upstream package version

## Artifact Map

Every non-trivial change must touch the right artifacts.

- `docs/audits/<topic>.md`
  - decision audit for the specific change, including a modeling-first inventory of tighter exact types, real polymorphism, split overloads, opaque classes, and other alternatives to `unknown`, JSON, or `%identity`
- `docs/audits/periodic-<scope>.md`
  - periodic or release audit record
- `docs/RELEASE_BLOCKERS.md`
  - active blocker list that outranks breadth work until the listed blockers are closed
- `docs/SOUNDNESS_MATRIX.md`
  - living map of important soundness boundaries and their tests
- in-source comments in affected `.res` and `.resi`
  - local rationale at hazardous or non-obvious boundaries
- `docs/TYPE_FIDELITY.md`
  - documented expressivity gaps between upstream TypeScript and public ReScript, including the strict supported subset and any intentionally unsupported upstream cases
- `docs/TYPE_SOUNDNESS_AUDIT.md`
  - current debt inventory for public `unknown`, `%identity`, `%raw`, and other boundary risks
- `README.md`
  - public-facing package shape when relevant

## Commit Attribution

When a human creates a commit that includes Codex-authored or materially Codex-assisted binding work, the commit message must include a Codex co-author trailer.

Use:

`Co-authored-by: Codex <codex@openai.com>`

This repo treats Codex as a real contributing author for materially assisted binding changes.

## Role Separation

Each change must be reviewed through these roles:

1. `Author`
2. `Adversarial Auditor`
3. `Release Gate Reviewer`

These roles may be performed by different agents or by the same maintainer in separate passes, but the adversarial pass must challenge the author's conclusions from the evidence record instead of extending the same reasoning stream.

## Workflow

### 1. Scope The Change

- identify the exact upstream exports and declarations involved
- identify whether the surface is exact upstream surface or package-authored helper surface
- identify the relevant boundary class:
  - exact binding
  - foreign input
  - foreign output
  - runtime classifier
  - helper surface

### 2. Gather Upstream Evidence

- inspect the relevant installed `.d.ts` files
- inspect official upstream docs
- inspect runtime behavior when docs and declarations do not fully settle the contract

Capture URLs, declarations, commands, and runtime probes in the audit report.

Before proceeding, read `docs/RELEASE_BLOCKERS.md`.

- if the change touches an open blocker, the work must either close that blocker or deepen the proof around it
- if the change does not close or advance an open blocker, it does not count as forward progress
- do not add breadth while blocker work is still open

### 3. Prove The Modeling Ceiling

Before accepting any open or lossy boundary, prove what the strongest honest public model can be.

- identify which upstream type parameters are semantically preserved at runtime and which are only caller convention
- identify whether a dynamic surface can be split into narrower functions, overloads, or package-owned algebraic data types
- identify whether opaque classes or branded values can be preserved directly instead of converting to JSON
- isolate the smallest irreducibly dynamic leaf instead of widening the entire surface
- if one awkward upstream edge case would force a weaker type across an otherwise well-modeled surface, prefer the stricter supported subset and record the unsupported remainder explicitly
- record each affected `unknown`, JSON projection, and `%identity` site in the audit, with the stronger alternative that was considered first

### 4. Design The Public Representation

- decide the `.resi` shape before or alongside implementation
- write down at least two alternatives when the choice is non-obvious
- explain why rejected alternatives are less truthful, less maintainable, less sound, or falsely precise

### 5. Implement

- use normal ReScript interop features first
- add or update in-source rationale comments where required
- keep the top-level export map thin

### 6. Capture Evidence

- run `npm run build`
- run `npm test` when binding code changed
- run `npm pack --dry-run` for release-facing work
- for any change that affects a public boundary or package-authored helper surface, add or update direct repo-owned tests that exercise the public binding surface itself
- when a public claim depends on compile-time rejection, express that through repo-owned type-shape test modules or compile-step fixtures inside this repo, not by recreating throwaway consumer apps
- ReScript-authored Vitest tests must be expressed through `rescript-vitest`, not a repo-owned replacement test DSL built from direct raw Vitest externals
- inspect emitted JS for representative tricky externals when claiming low-level or zero-cost interop
- record exact evidence in the audit report

Known-broken runtime behavior must never be counted as release-closing evidence just because a test reproduces it.

- if a public helper or public runtime call deterministically fails or emits broken output on a supported path, a passing regression test that encodes that failure is evidence for an open blocker, not evidence that the surface is healthy
- when the package intentionally keeps such a surface public temporarily, `docs/RELEASE_BLOCKERS.md`, `docs/TYPE_FIDELITY.md`, and the relevant audit must all say so explicitly
- release-closing proof requires either:
  - a working direct runtime demonstration on the supported path, or
  - a narrowed public contract that stops claiming the broken path is supported

### 7. Run Adversarial Audit

The adversarial pass must actively try to disprove the design.

It must ask questions like:

- could this `unknown`, JSON projection, or `%identity` site be replaced by a tighter exact model
- is this really a closed type
- is this really polymorphism
- does the runtime actually preserve the generic parameter
- did the binding preserve the upstream runtime class or did it flatten it into JSON
- are null, undefined, and omission separated correctly
- is the public `*Raw` API actually justified
- is this `%identity` a proved representational equality
- does the typed wrapper preserve upstream semantics
- could the API be split into narrower truthful pieces
- does the current documentation match the actual current public surface

### 8. Fix Or Reject

- fix the binding if the adversarial pass finds a problem
- tighten or document any remaining open boundary
- reject the change if the surface cannot yet be represented honestly

### 9. Release Gate Review

Before considering the work complete, verify:

- `docs/RELEASE_BLOCKERS.md` does not still list the affected blocker as open
- code, docs, and audit artifacts all agree
- the soundness matrix covers the affected boundary
- `docs/TYPE_FIDELITY.md` and `docs/TYPE_SOUNDNESS_AUDIT.md` are current
- every accepted `unknown`, JSON projection, or `%identity` site has a written reason why tighter modeling or real polymorphism was not truthful
- every unsupported upstream case is named explicitly, together with the stricter supported subset the package chose instead of widening the full surface
- any affected public boundary or helper surface has current direct test evidence recorded in the audit trail
- `README.md`, `.changeset/README.md`, `package.json`, and `.github/workflows/release.yml` agree on the release path
- the repository does not imply local `npm publish` as part of the maintainer workflow
- release publication is delegated to the repo's GitHub Actions workflow, not a local shell

## Retrofit Rule

When earlier work predates this process, backfill it under `docs/audits/`.

- create bootstrap audit records with stable names
- move scratch notes out of the repo root
- rewrite stale claims against the current observable repo state
- mark missing runtime proof explicitly instead of pretending it exists

## Naming Rules

- decision audits: `docs/audits/<subsystem>-<decision>.md`
  - example: `docs/audits/query-event-payloads.md`
- periodic audits: `docs/audits/periodic-<scope>.md`
  - example: `docs/audits/periodic-release-readiness.md`

Use stable descriptive names. Do not bury audit history in vague filenames.

## Completion Rule

A non-trivial binding change is incomplete until:

- the required artifacts exist
- `docs/RELEASE_BLOCKERS.md` was read and any affected blocker was updated
- the evidence chain is reproducible
- the adversarial pass has a written verdict
- the soundness matrix was updated
- the docs match the current public surface
- the release path documentation matches the actual workflow and local publish is not implied
