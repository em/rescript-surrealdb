> Historical contaminated audit. References below to clean-consumer proof are rejected and non-authoritative. Current authority is direct repo-owned `npm test` / Vitest evidence for the binding surface.

# Periodic Audit

## Historical Status

The release-blocking rows reopened here were closed on 2026-04-23 by `docs/audits/release-blocker-closure.md`.

## Scope

- trigger: broader fraud audit commissioned after the `1.0.1` release
- scope: public modeling quality of `unknown`, JSON, `%identity`, and generic/state surfaces
- reviewer: Codex
- date: 2026-04-23

## Surface Review

### Exact Modeling Opportunities

- reviewed:
  - `src/query/Surrealdb_Query.resi`
  - `src/query/Surrealdb_Select.resi`
  - `src/query/Surrealdb_Create.resi`
  - `src/query/Surrealdb_Update.resi`
  - `src/query/Surrealdb_Upsert.resi`
  - `src/query/Surrealdb_Delete.resi`
  - `src/query/Surrealdb_Insert.resi`
  - `src/query/Surrealdb_Relate.resi`
  - `src/query/Surrealdb_Run.resi`
  - `src/connection/Surrealdb_Auth.resi`
  - `src/api/Surrealdb_ApiPromise.resi`
  - `src/live/Surrealdb_Live.resi`
  - `src/value/Surrealdb_RecordId.resi`
- findings:
  - The strongest immediately available public model is stricter than the current surface on several promise builders.
  - Upstream explicitly tracks JSON mode with `J extends boolean`, but the public binding often erases that state entirely.
  - Upstream separates output payload types from input binding types, but several current constructors return `t<Surrealdb_JsValue.t>`, which collapses input and output domains.

### Unsupported Upstream Surface

- reviewed:
  - `docs/TYPE_FIDELITY.md`
  - `docs/process/BINDING_PROOF_PROCESS.md`
  - `docs/process/SOUNDNESS_COVERAGE.md`
- findings:
  - The repo did not previously require each fidelity gap to name the strict supported subset and the intentionally unsupported remainder.
  - That process gap is now corrected in the process docs and templates.
  - The current repo state still needs follow-up design work to document which CRUD/query/live result-shape cases are intentionally unsupported instead of weakly typed.

### Public `unknown` Boundaries

- reviewed:
  - `src/value/Surrealdb_RangeBound.resi`
  - `src/value/Surrealdb_ValueCodec.resi`
  - `src/value/Surrealdb_CborCodec.resi`
  - `src/errors/Surrealdb_ServerError.resi`
  - classifier surfaces across `src/value/`, `src/errors/`, and `src/live/`
- findings:
  - Many public `unknown` sites are still honest classifier or codec seams.
  - The broader concern is not every `unknown` in isolation; it is whether `unknown` was chosen before exhausting tighter models on nearby public surfaces.
  - The reopened weak rows are concentrated on promise builders and state surfaces, not on the classifier modules themselves.

### Public JSON Projections

- reviewed:
  - `src/value/Surrealdb_RecordId.resi`
  - `src/support/Surrealdb_Jsonify.resi`
  - geometry `toJSON` surfaces under `src/value/`
- findings:
  - `RecordId.idValue` compound ids remain a package-authored JSONified projection, not the exact upstream `unknown[] | Record<string, unknown>` surface.
  - `Jsonify.value` is an intentional package boundary and has direct runtime proof, but it cannot justify erasing JSON mode on unrelated promise builders.

### Public `%identity`, `Obj.magic`, `%raw`

- reviewed:
  - `%identity` sites in `src/query/Surrealdb_QueryFrame.res`
  - `%identity` sites in `src/live/Surrealdb_Frame.res`
  - `%identity` sites in `src/value/Surrealdb_RecordId.res`
  - package-local `%identity` test helpers in `tests/query/SurrealdbPublicSurface_test.res` and `tests/connection/SurrealdbSessionSurface_test.res`
- findings:
  - Many internal `%identity` sites are still representation-sealing or classifier casts.
  - The current proof story is weakened because package-local `%identity` test helpers are still used to inspect resolved CRUD/query outputs and `RangeBound` inputs.
  - That pattern does not satisfy the clean external consumer proof requirement.

### Public `*Raw` APIs

- reviewed:
  - `Surrealdb_Surreal.*Raw`
  - `Surrealdb_Session.*Raw`
  - `Surrealdb_Update.outputRaw`
  - `Surrealdb_ServerError.makeRpcError*`
- findings:
  - The main broader-fraud issues are not the existing `*Raw` APIs.
  - The sharper defects are the typed promise-builder surfaces that still claim the wrong result state.

### Fidelity Gaps

- reviewed:
  - `docs/TYPE_FIDELITY.md`
  - `node_modules/surrealdb/dist/surrealdb.d.ts`
- findings:
  - `TYPE_FIDELITY.md` now documents the need to name strict supported subsets and unsupported remainders.
  - It still needs future follow-up entries once the CRUD/query/live result redesign is chosen.
  - The current public `.json()` surfaces are not acceptable as a settled fidelity gap because they preserve a payload state the upstream declaration explicitly changes.

### Helper Surfaces

- reviewed:
  - `Surrealdb_Query` helper constructors
  - `Surrealdb_JsValue`
  - `Surrealdb_RecordId.idValue`
- findings:
  - `Surrealdb_Query` helper constructors remain clearly package-added and are not the primary fraud source here.
  - `Surrealdb_JsValue` is an input boundary helper, but it is currently leaking into output-side promise builder types.

## Documentation Sync

- `docs/TYPE_FIDELITY.md` current:
  - improved at the process level, but still missing the eventual explicit unsupported-surface entries for CRUD/query/live result redesign
- `docs/TYPE_SOUNDNESS_AUDIT.md` current:
  - updated in this audit to record reopened weak rows
- `docs/SOUNDNESS_MATRIX.md` current:
  - updated in this audit to add weak rows for promise output-domain fidelity and `.json()` state fidelity
- stale items:
  - no remaining stale item should claim the public promise-builder surface is already settled

## Coverage Review

- uncovered important boundaries:
  - direct runtime proof for `.json()` mode on public CRUD/query/auth/api builders
  - clean external consumer proof for resolved CRUD/query outputs without package-local `%identity`
  - compound `RecordId.idValue` coverage for non-trivial nested payloads
- stale tests:
  - package-local `%identity`-based tests still stand in for some external-consumer proofs
- missing direct tests:
  - tests that fail if `.json()` preserves the wrong public payload type
  - tests that fail if CRUD/query builders keep leaking `Surrealdb_JsValue.t` into output positions

## Actions

- tighten:
  - redesign public promise-builder state so JSON mode and output-domain modeling are explicit
  - require clean consumer proofs for any public boundary currently exercised only through package-local `%identity`
- deprecate:
  - none yet; redesign should happen before deprecation decisions
- document:
  - strict supported subset versus unsupported remainder for any redesigned CRUD/query/live result surface
- defer with explicit debt:
  - exact user-facing redesign is still pending, but the current weak rows are now recorded openly instead of being treated as settled

## Required Refactoring Direction

Any runtime failure path that survives into the ordinary typed consumer path because the package erased a modelable distinction is fraud.

The required correction for this package line is:

- model resolved output domains separately from input binding domains
- model JSON-mode state explicitly on promise builders instead of erasing it
- keep codec, event, and raw transport heterogeneity isolated to explicit open seams
- stop using package-local `%identity` test recovery as proof for public consumer ergonomics
- prove the redesigned surface through clean external consumers, not only internal package tests

This review remains release-blocking until the corresponding rows in `docs/RELEASE_BLOCKERS.md` are closed.

## Verdict

- release ready:
  - no, not for a stronger soundness claim about the whole public surface
- not release ready:
  - the current repo state still contains weak promise-builder fidelity around output-domain modeling and `.json()` state
- notes:
  - this audit does not claim every `unknown`, JSON projection, or `%identity` site is fraudulent
  - it identifies the current systemic defects where the package still weakens or lies about a more modelable public surface
