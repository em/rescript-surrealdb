# Periodic Audit

## Scope

- trigger: `statespace` consumer review after the `1.0.1` release
- scope: published `rescript-surrealdb@1.0.1` as consumed by `statespace`
- reviewer: Codex
- date: 2026-04-23

## Surface Review

### Public `unknown` Boundaries

- reviewed:
  - `src/value/Surrealdb_Value.resi`
  - `src/value/Surrealdb_RecordId.resi`
  - `src/support/Surrealdb_JsValue.resi`
  - `src/connection/Surrealdb_Surreal.resi`
  - `src/connection/Surrealdb_Session.resi`
  - `src/live/Surrealdb_Live.resi`
  - `src/live/Surrealdb_LiveMessage.resi`
  - `src/query/Surrealdb_Query.resi`
- findings:
  - The statespace-used path no longer exposes the old fake-polymorphic decode shape.
  - The remaining open boundaries on the reviewed path are still classifier or codec boundaries and are named as such.
  - No new public `'a`-pretending-to-be-foreign-data surface was found in the reviewed statespace-used modules.

### Public `%identity`, `Obj.magic`, `%raw`

- reviewed:
  - `src/value/Surrealdb_RecordId.res`
  - `src/query/Surrealdb_QueryFrame.res`
  - `src/errors/Surrealdb_ClientError.res`
  - `src/errors/Surrealdb_ServerError.res`
  - `src/value/Surrealdb_Value.res`
  - `src/value/Surrealdb_BoundValue.res`
- findings:
  - The reviewed `%identity` sites on the statespace-used path are internal classifier casts or representation-sealing casts.
  - `Obj.magic` remains absent.
  - `%raw` remains absent.

### Public `*Raw` APIs

- reviewed:
  - `Surrealdb_Surreal.*Raw`
  - `Surrealdb_Session.*Raw`
  - `Surrealdb_Update.outputRaw`
  - `Surrealdb_QueryResponse.*Raw`
  - `Surrealdb_ServerError.makeRpcError*`
- findings:
  - The statespace callsites reviewed use the typed wrappers, not the raw forms.
  - The remaining public `*Raw` APIs are narrow exact-upstream or package-added low-level escape hatches.

### Fidelity Gaps

- reviewed:
  - `docs/TYPE_FIDELITY.md`
  - `src/value/Surrealdb_RecordId.res`
  - `src/value/Surrealdb_RecordId.resi`
  - `docs/process/BINDING_PROOF_PROCESS.md`
- findings:
  - `docs/TYPE_FIDELITY.md` now records the `Surrealdb_RecordId.idValue` package-owned union, but it still does not explicitly say that compound ids are normalized through `surrealdb.jsonify` into `ArrayId(array<JSON.t>) | ObjectId(dict<JSON.t>)`.
  - The environment-default WebSocket fidelity gap is now documented correctly.

### Helper Surfaces

- reviewed:
  - `Surrealdb_Query.statement`
  - `Surrealdb_JsValue.bindings`
  - `Surrealdb_RecordId.make`
  - `Surrealdb_Surreal.defaultWebSocketImpl`
- findings:
  - A clean throwaway ReScript 12 consumer compiled a statespace-like harness using these helpers against the published `1.0.1` package.
  - The package root import also succeeded after the consumer build.

## Documentation Sync

- `docs/TYPE_FIDELITY.md` current:
  - improved, but still incomplete on `RecordId.idValue` compound-id normalization
- `docs/TYPE_SOUNDNESS_AUDIT.md` current:
  - not re-audited in full here
- `docs/SOUNDNESS_MATRIX.md` current:
  - current enough to describe the main boundaries, but it still does not encode a clean consumer-proof gate
- stale items:
  - `docs/TYPE_FIDELITY.md` should explicitly document the `RecordId.idValue` compound-id normalization through `jsonify`
  - release-path docs should explicitly require a packed-artifact clean-consumer proof

## Coverage Review

- uncovered important boundaries:
  - no release-process requirement today forces the package through a clean external consumer build after packing
  - no explicit periodic audit gate proves a modest statespace-like consumer surface on every release
- stale tests:
  - none identified on the small surface exercised here
- missing direct tests:
  - direct tests for `RecordId.idValue` compound `ArrayId` and `ObjectId`
  - a release-path proof that installs the packed artifact into a clean ReScript consumer and runs top-level `rescript build`
  - a modest consumer harness exercising the public helpers that real app code uses together

## Actions

- tighten:
  - add an explicit packed-artifact clean-consumer proof step to `docs/process/BINDING_PROOF_PROCESS.md`
- deprecate:
  - none from this review
- document:
  - add the explicit `RecordId.idValue` compound-id normalization note to `docs/TYPE_FIDELITY.md`
  - document the clean-consumer proof in the release-facing audit trail
- defer with explicit debt:
  - broader consumer-harness testing is still process debt; the package can pass its own suite while missing modest consumer-shaped gaps unless that proof is added to the release gate

## Verdict

- release ready:
  - yes, for the modest `statespace` consumer surface exercised here
- not release ready:
  - no statespace-blocking package soundness defect was reproduced in the published `1.0.1` package on the exercised path
- notes:
  - The package is materially better than `1.0.0` on the Node 20 / environment-default boundary.
  - The remaining issue exposed by this review is mostly test-infrastructure and release-proof debt, not a reproduced package break on the exercised consumer path.
  - Evidence run for this audit:
    - `npm view rescript-surrealdb version dist-tags time --json`
    - clean throwaway consumer install of `rescript-surrealdb@1.0.1`
    - top-level `npx rescript build` in that consumer
    - post-build package import probe
