# Public Boundary Tightening Audit

## Historical Status

The later `RangeBound`, promise-output, JSON-state, and consumer-proof design now lives in `docs/audits/release-blocker-closure.md`.

## Claim

- subsystem: public value, live, error, and API boundaries
- change: replace fake public generics with explicit open boundaries, add direct tests at the remaining weak spots, and correct numeric edge classification in `Surrealdb_Value.fromUnknown`
- boundary class: runtime classifier boundaries, optional-field boundaries, fulfillment-helper boundaries, package fidelity gaps
- exact public surface affected:
  - `src/errors/Surrealdb_ClientError.resi`
  - `src/live/Surrealdb_Frame.resi`
  - `src/value/Surrealdb_RangeBound.resi`
  - `src/api/Surrealdb_ApiPromise.resi`
  - `src/api/Surrealdb_ApiResponse.resi`
  - `src/support/Surrealdb_Jsonify.resi`
  - `src/live/Surrealdb_LiveMessage.resi`
  - `src/value/Surrealdb_Value.res`

## Upstream Evidence

### Official Docs

- URL: https://surrealdb.com/docs/sdk/javascript/core/streaming
  - relevant excerpt or summary: live queries emit action, record id, and changed value payloads at runtime, so the binding must classify the payload honestly instead of claiming a caller-chosen type.
- URL: https://surrealdb.com/docs/sdk/javascript
  - relevant excerpt or summary: the SDK exposes typed runtime value classes and Promise-like query and API builders, but query results and live data still depend on runtime input.
- URL: https://rescript-lang.org/docs/manual/bind-to-js-function/
  - relevant excerpt or summary: `unknown` is the correct public type for foreign values that the binding cannot prove more precisely.

### Declaration Evidence

- file: `node_modules/surrealdb/dist/surrealdb.d.ts`
  - relevant signature:
    - `export declare class BoundIncluded<T> { readonly value: T; constructor(value: T); }`
    - `export declare class BoundExcluded<T> { readonly value: T; constructor(value: T); }`
    - `declare abstract class DispatchedPromise<T> extends Promise<T> { then<TResult1 = T, TResult2 = never>(...) }`
    - `declare class ApiPromise<Req, Res, V extends boolean = false, J extends boolean = false> extends DispatchedPromise<...>`
    - `interface ApiResponse<T> { body?: T; headers?: Record<string, string>; status?: number; }`

### Runtime Evidence

- command or probe:
  - `rg -n "2147483648|2147483647|Math\\.floor" src/value/Surrealdb_Value.mjs`
  - `sed -n '1,80p' src/live/Surrealdb_LiveMessage.mjs`
  - `sed -n '1,80p' src/api/Surrealdb_ApiResponse.mjs`
  - `sed -n '1,80p' src/api/Surrealdb_ApiPromise.mjs`
- result:
  - emitted JS now uses `raw >= -2147483648.0 && raw <= 2147483647.0` for integer recovery
  - `LiveMessage.value` is a direct `Surrealdb_Value.fromUnknown(message.value)` classification
  - `ApiResponse.body`, `headers`, and `status` all compile to `fromNullable(...)` accessors
  - `ApiPromise.then_` remains a direct `prim.then(prim1)` fulfillment helper

## Local Representation

- affected files:
  - `src/errors/Surrealdb_ClientError.resi`
  - `src/live/Surrealdb_Frame.resi`
  - `src/value/Surrealdb_RangeBound.resi`
  - `src/value/Surrealdb_Value.res`
  - `tests/errors/SurrealdbErrorSupport_test.res`
  - `tests/query/SurrealdbPublicSurface_test.res`
  - `tests/value/SurrealdbValueSurface_test.res`
  - `tests/connection/SurrealdbSessionSurface_test.res`
  - `docs/TYPE_FIDELITY.md`
  - `docs/TYPE_SOUNDNESS_AUDIT.md`
  - `docs/SOUNDNESS_MATRIX.md`
- chosen ReScript shape:
  - `ClientError.asXxx` accepts `unknown`
  - `Frame.fromUnknown` returns `option<t<unknown>>`
  - `RangeBound.included` and `excluded` accept `unknown`
  - `Value.fromUnknown` preserves int boundaries honestly
  - `ApiResponse` optional fields stay optional and classify `body` through `Surrealdb_Value`
  - `ApiPromise.then_` stays documented as a fulfillment-preserving helper rather than a full Promise abstraction

## Alternatives Considered

### Alternative 1

- representation: keep public `'a` on `ClientError.asXxx`, `RangeBound`, and `Frame.fromUnknown`
- why rejected: those type variables were not proven by the runtime. They only hid uncertainty behind polymorphic syntax.

### Alternative 2

- representation: widen everything to `unknown` and drop the typed wrappers entirely
- why rejected: the SDK does prove several boundaries at runtime, and the binding already has direct classifiers for values, errors, live messages, engines, and API responses.

## Adversarial Questions

- question: does changing `RangeBound` to `unknown` lose useful type information compared with the TypeScript generic
- evidence-based answer: yes, but the old `'a` was fake precision. The runtime constructor accepts an arbitrary JS value, and ReScript cannot recover that caller-chosen type later.

- question: is `ApiPromise.then_` still narrower than the upstream Promise-like surface
- evidence-based answer: yes. The full overload set remains a documented fidelity gap in `docs/TYPE_FIDELITY.md`. The public helper is intentionally limited to the common fulfillment-preserving path.

- question: does `Jsonify.value` still rely on the SDK contract
- evidence-based answer: yes. The binding still trusts the SDK to return JSON-compatible data, but the direct test now verifies nested SDK values stringify and parse back correctly on the installed version.

## Failure Modes Targeted

- failure mode: non-errors classify as client errors because the public API accepts any `'a`
- how the current design prevents or exposes it: the boundary is now explicitly `unknown`, and the direct test passes both real SDK errors and non-errors
- test or probe covering it: `tests/errors/SurrealdbErrorSupport_test.res`

- failure mode: callers manufacture a typed live frame payload through `Frame.fromUnknown`
- how the current design prevents or exposes it: the public return is now `option<t<unknown>>`
- test or probe covering it: `tests/query/SurrealdbPublicSurface_test.res`

- failure mode: range-bound constructors pretend to preserve a caller type they cannot prove
- how the current design prevents or exposes it: the public input is now `unknown`, and the tests round-trip actual bound values through the public API
- test or probe covering it: `tests/value/SurrealdbValueSurface_test.res`, `tests/query/SurrealdbPublicSurface_test.res`

- failure mode: live payloads or API responses drift from the classified value boundaries
- how the current design prevents or exposes it: direct tests now classify `LiveMessage.value`, `ApiResponse.body`, and `ApiPromise.then_` results on the installed SDK
- test or probe covering it: `tests/connection/SurrealdbSessionSurface_test.res`

- failure mode: numeric edge cases are misclassified at the `Value.fromUnknown` boundary
- how the current design prevents or exposes it: the integer guard now includes the lower bound and the test suite covers NaN, infinities, and out-of-range integers
- test or probe covering it: `tests/value/SurrealdbValueSurface_test.res`

## Evidence

### Build

- command: `npm run build`
- result: passed

### Tests

- command: `npx vitest run tests/value/SurrealdbValueSurface_test.mjs tests/query/SurrealdbPublicSurface_test.mjs tests/connection/SurrealdbSessionSurface_test.mjs --config vitest.config.js`
- result: passed, 39 tests
- command: `npm test`
- result: passed, 54 tests and coverage report
- command: `npm pack --dry-run`
- result: passed and produced `rescript-surrealdb-0.1.0.tgz`

### Emitted JS Inspection

- file or command:
  - `rg -n "2147483648|2147483647|Math\\.floor" src/value/Surrealdb_Value.mjs`
  - `sed -n '1,80p' src/live/Surrealdb_LiveMessage.mjs`
  - `sed -n '1,80p' src/api/Surrealdb_ApiResponse.mjs`
  - `sed -n '1,80p' src/api/Surrealdb_ApiPromise.mjs`
- result: verified direct runtime classification for live payloads and optional API fields, direct `then` forwarding for `ApiPromise.then_`, and corrected integer bounds in emitted JS

### Soundness Matrix Update

- affected row:
  - `Value / RangeBound open input boundary`
  - `Errors / ClientError.asXxx unknown boundary`
  - `Live / Frame.fromUnknown open classifier`
  - `Live / event payload boundary`
  - `Connection / engine subtype casts`
  - `API / optional response fields`
  - `API / ApiPromise.then_ fulfillment helper`
  - `Support / Jsonify unknown-to-JSON cast`
- update made: removed the remaining `weak` and `missing` rows by either tightening the public surface or adding a direct boundary test

## Residual Risk

- remaining open boundary: query results, event tuples, codec payloads, and raw server error details remain value-dependent
- why it remains open: the installed SDK does not provide a runtime proof strong enough to close those boundaries without lying
- where it is documented: `docs/TYPE_FIDELITY.md`, `docs/TYPE_SOUNDNESS_AUDIT.md`, `docs/SOUNDNESS_MATRIX.md`

## Verdict

- status:
  - acceptable with documented fidelity gap
- reviewer: Codex
- date: 2026-04-22
