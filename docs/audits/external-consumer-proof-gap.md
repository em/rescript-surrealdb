> Historical contaminated audit. References below to external-consumer or packed-consumer proof are rejected and non-authoritative. Current authority is direct repo-owned `npm test` / Vitest evidence for the binding surface.

# External Consumer Proof Gap Audit

## Historical Status

This gap report was closed on 2026-04-23 by `docs/audits/release-blocker-closure.md`.

## Claim

- subsystem: external consumer proof, public `unknown` boundaries, and release-facing soundness coverage
- change: identify whether the `1.0.1` package proof is strong enough for real consumer use and whether package tests can still pass while a normal ReScript consumer hits public-surface friction
- boundary class: public `unknown` boundaries, package-authored helper surfaces, release gate coverage
- exact public surface affected:
  - `src/value/Surrealdb_RangeBound.resi`
  - `src/value/Surrealdb_RecordId.resi`
  - `src/value/Surrealdb_CborCodec.resi`
  - `src/value/Surrealdb_ValueCodec.resi`
  - `src/query/Surrealdb_Export.resi`
  - `src/query/Surrealdb_Expr.resi`
  - `src/connection/Surrealdb_Surreal.resi`
  - `src/support/Surrealdb_JsValue.resi`
  - `docs/process/BINDING_PROOF_PROCESS.md`
  - `docs/process/SOUNDNESS_COVERAGE.md`

## Upstream Evidence

### Official Docs

- URL: https://rescript-lang.org/docs/manual/external
  - relevant excerpt or summary: `unknown` is the correct representation for foreign values that the binding cannot prove more precisely.
- URL: https://rescript-lang.org/docs/manual/v11.0.0/build-overview
  - relevant excerpt or summary: a top-level consumer `rescript build` is the real consumer contract for package usability.

### Declaration Evidence

- file: `node_modules/surrealdb/dist/surrealdb.d.ts`
  - relevant signature:
    - `new RecordId(table: string | Table, id: string | number | Uuid | bigint | unknown[] | Record<string, unknown>)`
    - `new BoundIncluded<T>(value: T)`
    - `new BoundExcluded<T>(value: T)`

### Runtime Evidence

- command or probe:
  - `npm test`
  - `npm pack --dry-run`
  - clean consumer install/build of `rescript-surrealdb@1.0.1`
  - broader clean-consumer compile probe using `RangeBound.included(rid)`
- result:
  - package-local build and tests pass
  - packed artifact exists
  - a modest external consumer compiles and imports the package
  - a broader external consumer fails to compile `Surrealdb_RangeBound.included(rid)` because the public API expects `unknown`, not a typed `Surrealdb_RecordId.t`

## Local Representation

- affected files:
  - `src/value/Surrealdb_RangeBound.resi`
  - `src/value/Surrealdb_RecordId.res`
  - `tests/query/SurrealdbPublicSurface_test.res`
  - `tests/value/SurrealdbValueSurface_test.res`
  - `tests/value/SurrealdbBindingValue_test.res`
  - `tests/errors/SurrealdbErrorPayloadSurface_test.res`
  - `tests/errors/SurrealdbErrorSupport_test.res`
  - `tests/connection/SurrealdbSessionSurface_test.res`
- chosen ReScript shape:
  - several public boundaries remain intentionally open as `unknown`
  - the package test suite drives many of those boundaries through local `%identity` helpers such as `toUnknown`, `intToUnknown`, `stringToUnknown`, and `dictToUnknown`

## Alternatives Considered

### Alternative 1

- representation: accept the internal test suite as sufficient proof for public `unknown` boundaries
- why rejected: the suite can still pass while a normal external consumer cannot call the public API without its own unsafe cast.

### Alternative 2

- representation: close every `unknown` boundary to one precise package type
- why rejected: some upstream boundaries are genuinely open and cannot be closed honestly without lying about runtime behavior.

## Adversarial Questions

- question: if the package already has tests for `RangeBound.included`, why is this still a consumer-proof gap
- evidence-based answer: the tests only drive that boundary through local `%identity` helpers such as `intToUnknown(7)` or `table->toUnknown`. A normal external consumer calling `Surrealdb_RangeBound.included(rid)` does not compile.

- question: does the broader consumer failure prove the binding is entirely broken
- evidence-based answer: no. A modest external consumer compiles successfully on `1.0.1`. The problem is narrower: the release gate still allows real consumer-shape friction on specific public open boundaries.

- question: is `RecordId.idValue` still raw `unknown`
- evidence-based answer: no. It is a package-owned union. The remaining fidelity gap is that compound ids are normalized through `surrealdb.jsonify` into JSON-backed shapes, and that normalization still has only partial proof.

## Failure Modes Targeted

- failure mode: a package test passes because it injects `unknown` with `%identity`, but a normal external consumer cannot call the same public API
- how the current design prevents or exposes it: it does not prevent it today; the broader external consumer compile probe exposed it directly
- test or probe covering it:
  - clean consumer compile failure on `Surrealdb_RangeBound.included(rid)`

- failure mode: release documentation treats `npm pack --dry-run` as sufficient package proof
- how the current design prevents or exposes it: it does not; the current proof process has no required clean-consumer gate
- test or probe covering it:
  - `docs/process/BINDING_PROOF_PROCESS.md`

- failure mode: package docs overstate soundness coverage while broad public surfaces remain weakly exercised
- how the current design prevents or exposes it: the coverage report exposes the gap
- test or probe covering it:
  - `npm test` coverage report

## Evidence

### Build

- command: `npm run build`
- result: passed

### Tests

- command: `npm test`
- result: passed, 55 tests
- command: `npm pack --dry-run`
- result: passed and produced `rescript-surrealdb-1.0.1.tgz`

### Emitted JS Inspection

- file or command:
  - `nl -ba src/value/Surrealdb_RecordId.res | sed -n '64,79p'`
  - `nl -ba src/value/Surrealdb_RangeBound.resi | sed -n '1,40p'`
- result:
  - `RecordId.idValue` still normalizes compound ids through `jsonify`
  - `RangeBound.included` / `excluded` still expose `unknown => t`

### Soundness Matrix Update

- affected row:
  - `Value / RecordId.idValue classification`
  - `Export/Helpers / package-authored helper surface`
- update made:
  - none yet in the matrix itself; this audit records the gap that the matrix and proof process need to cover more directly

## Residual Risk

- remaining open boundary:
  - public `unknown` boundaries that are only exercised through package-internal cast helpers
- why it remains open:
  - the package still lacks a required external-consumer proof gate for those boundaries
- where it is documented:
  - `docs/process/BINDING_PROOF_PROCESS.md`
  - `docs/process/SOUNDNESS_COVERAGE.md`
  - this audit

## Verdict

- status:
  - acceptable with documented fidelity gap
  - rejected as sufficient consumer proof until the release gate includes a clean external consumer check for public open boundaries
- reviewer: Codex
- date: 2026-04-23

## Required Correction

There is no acceptable package state where an ordinary typed consumer path can still fail because the package left a more modelable public boundary open or only proved it through package-local casts.

For the current SurrealDB package line, the required broad refactor is:

- separate input binding types from resolved output-domain types on CRUD/query/live/auth/api promise builders
- make `.json()` state explicit instead of preserving the same `'value` before and after JSON mode
- keep raw or heterogeneous protocol and codec seams explicit secondary surfaces
- keep the typed 99% path free of package-authored `%identity`-style consumer recovery
- require clean packed-artifact external-consumer proof for any public boundary that package tests currently satisfy through local cast helpers

## Release Blocker Mapping

This audit currently keeps these blocker rows open in `docs/RELEASE_BLOCKERS.md`:

- Blocker 1: Promise builders still blur input and resolved output domains
- Blocker 2: `.json()` state is still not explicit
- Blocker 3: Public open boundaries still hide consumer friction
- Blocker 4: Compound `RecordId.idValue` fidelity is still only partially proved
