# Release Blocker Closure Audit

## Claim

- subsystem: promise builders, JSON-mode state, typed boundary design, packed consumer proof
- change: separate input-side binding types from resolved output domains, model `.json()` explicitly, tighten `RangeBound` and `RecordId.idValue` to supported recursive subsets, and add a packed-artifact clean-consumer proof
- boundary class: ordinary typed consumer path, explicit open codec boundary, supported-subset runtime classification
- exact public surface affected:
  - `src/query/Surrealdb_Query.resi`
  - `src/query/Surrealdb_Select.resi`
  - `src/query/Surrealdb_Create.resi`
  - `src/query/Surrealdb_Update.resi`
  - `src/query/Surrealdb_Upsert.resi`
  - `src/query/Surrealdb_Delete.resi`
  - `src/query/Surrealdb_Insert.resi`
  - `src/query/Surrealdb_Relate.resi`
  - `src/query/Surrealdb_Run.resi`
  - `src/query/Surrealdb_JsonFrame.resi`
  - `src/connection/Surrealdb_Auth.resi`
  - `src/live/Surrealdb_Live.resi`
  - `src/api/Surrealdb_ApiPromise.resi`
  - `src/api/Surrealdb_ApiJsonResponse.resi`
  - `src/value/Surrealdb_RangeBound.resi`
  - `src/value/Surrealdb_RecordId.resi`
  - `scripts/packedConsumerProof.mjs`

## Upstream Evidence

### Declaration Evidence

- file: `node_modules/surrealdb/dist/surrealdb.d.ts`
  - relevant signatures:
    - `query<R extends unknown[] = unknown[]>(...) => Query<R>`
    - `json(): Query<R, true>`
    - `select<T>(...) => SelectPromise<..., T, false>`
    - `json(): SelectPromise<T, I, true>`
    - equivalent `json(): ...Promise<..., true>` signatures on `Create`, `Update`, `Upsert`, `Delete`, `Insert`, `Relate`, `Run`, and `AuthPromise`
    - `class ApiPromise<Req, Res, V extends boolean = false, J extends boolean = false>`
    - `value(): ApiPromise<Req, Res, true, J>`
    - `json(): ApiPromise<Req, Res, V, true>`
    - `type RecordIdValue = string | number | Uuid | bigint | unknown[] | Record<string, unknown>`
    - `class BoundIncluded<T> { readonly value: T }`
    - `class BoundExcluded<T> { readonly value: T }`

### Runtime Evidence

- file: `node_modules/surrealdb/dist/surrealdb.mjs`
  - result:
    - `ApiPromise.stream()` continues to stream response envelopes even after `value()`
    - `.json()` flips the runtime JSON mode
- probes:
  - direct tests in `tests/connection/SurrealdbSessionSurface_test.res`
    - query/select/auth/API `.json()` results are observed at runtime
  - direct tests in `tests/value/SurrealdbValueSurface_test.res`
    - `RecordId.idValue` covers nested arrays, nested objects, nested value-class leaves, and unsupported nested function leaves
  - packed consumer proof in `scripts/packedConsumerProof.mjs`
    - installs the packed tarball into a clean ReScript app
    - compiles a consumer that exercises the redesigned typed path and the remaining intentional open codec boundaries
    - runs runtime checks against the compiled consumer artifact

## Local Representation

- chosen ReScript shape:
  - `Query` resolves to `array<Surrealdb_Value.t>` on the ordinary path and `array<JSON.t>` after `.json()`
  - CRUD builders and `Auth` resolve to `Surrealdb_Value.t` on the ordinary path and `JSON.t` after `.json()`
  - `Live` no longer exports a fake payload generic; the builder resolves to `Surrealdb_LiveSubscription.t`
  - `ApiPromise` now separates response/body mode from value/JSON format:
    - `t<responseMode, valueFormat>`
    - `t<responseMode, jsonFormat>`
    - `t<bodyMode, valueFormat>`
    - `t<bodyMode, jsonFormat>`
  - `RangeBound` constructor input is a closed recursive supported subset:
    - `Undefined | Null | Bool | Int | Float | String | BigInt | ValueClass | Array | Object`
  - `RangeBound.value` remains a classifier over the broader runtime boundary through `Surrealdb_BoundValue.t`
  - `RecordId.idValue` is a closed supported subset plus explicit unsupported remainder:
    - `option<idValue>`
    - nested compound leaves use recursive `component`
    - unsupported nested leaves return `None` instead of being flattened or fabricated

## Alternatives Considered

### Alternative 1

- representation: preserve caller-chosen `'value` or `'a` across CRUD/query/live/API builders
- why rejected: the runtime does not preserve those type variables semantically; the older surface only reused input-side types or fake polymorphism

### Alternative 2

- representation: keep `RangeBound` and `RecordId.idValue` open as raw `unknown`
- why rejected: the supported recursive subset is strong enough to model directly, and leaving it open would force avoidable consumer friction onto the typed 99% path

### Alternative 3

- representation: preserve full upstream `unknown[] | Record<string, unknown>` for compound record ids
- why rejected: the public package cannot soundly reclassify arbitrary nested leaves back into an ML type without either lying or exporting a broader escape hatch than necessary

## Adversarial Questions

- question: why is the ordinary typed path keyed to `Surrealdb_Value.t` and `JSON.t` instead of a caller-supplied record type
- evidence-based answer: the upstream generics are caller intent, schema intent, or query-text intent, not runtime-preserved ML polymorphism. The strongest honest public shape is classified Surreal values on the ordinary path and explicit JSON values after `.json()`.

- question: why does `ApiPromise` need two phantom axes
- evidence-based answer: upstream tracks both response-envelope/body mode and value/JSON mode. Collapsing those axes had already produced false public states.

- question: why does `RecordId.idValue` return `option<idValue>`
- evidence-based answer: nested function and similar non-reclassifiable leaves exist at runtime. Returning `None` is the narrow honest outcome for the unsupported remainder.

- question: why do codec boundaries remain open
- evidence-based answer: the upstream codec surface is intentionally dynamic. The package can require consumer classification for `decodeWith`, but it cannot truthfully choose the final `'value` on behalf of the caller.

## Failure Modes Targeted

- failure mode: CRUD/query/live/auth/API builders leak input-side `Surrealdb_JsValue.t` into resolved output positions
- how the current design prevents or exposes it: the public `.resi` files now separate builder input configuration from resolved output domains
- test or probe covering it: `tests/query/SurrealdbPublicSurface_test.res`, `tests/connection/SurrealdbSessionSurface_test.res`, `scripts/packedConsumerProof.mjs`

- failure mode: `.json()` preserves the same public payload shape before and after the mode transition
- how the current design prevents or exposes it: `.json()` now changes the public format type directly, and direct tests plus the consumer proof compile would fail if that regressed
- test or probe covering it: `tests/query/SurrealdbPublicSurface_test.res`, `tests/connection/SurrealdbSessionSurface_test.res`, `scripts/packedConsumerProof.mjs`

- failure mode: range-bound construction still requires `unknown` or a wider public algebra than the constructor can really preserve
- how the current design prevents or exposes it: the constructor now accepts only the supported recursive subset, while `value()` still classifies broader runtime leaves when they come from foreign JS
- test or probe covering it: `tests/query/SurrealdbPublicSurface_test.res`, `tests/value/SurrealdbValueSurface_test.res`, `scripts/packedConsumerProof.mjs`

- failure mode: compound record ids are flattened through JSON or misreported as always supported
- how the current design prevents or exposes it: compound ids use a recursive algebraic subset, nested value-class leaves round-trip, and unsupported nested leaves return `None`
- test or probe covering it: `tests/value/SurrealdbValueSurface_test.res`, `scripts/packedConsumerProof.mjs`

- failure mode: package-local `%identity` helpers overstate public consumer proof
- how the current design prevents or exposes it: the packed tarball is installed into a clean consumer that compiles and runs against only the published package surface
- test or probe covering it: `scripts/packedConsumerProof.mjs`

## Evidence

### Build

- command: `npm run build`
- result: passed

### Tests

- command: `npm test`
- result: passed, 59 tests plus packed-consumer proof
- command: `npm pack --dry-run`
- result: passed and produced `rescript-surrealdb-1.0.1.tgz`

### Packed Consumer Proof

- command: `npm run test:consumer`
- result: passed
- proof details:
  - `npm pack --json` created the current tarball
  - a throwaway consumer installed the tarball with `surrealdb`, `rescript`, and `rescript-webapi`
  - `npx rescript build` succeeded in that consumer
  - runtime checks succeeded for:
    - query/auth typed path
    - `RangeBound` supported constructor path
    - `RecordId.idValue` supported subset and unsupported remainder
    - `CborCodec` and `ValueCodec` decode boundaries

### Soundness Matrix Update

- affected rows:
  - `Value / RecordId.idValue classification`
  - `Value / RangeBound constructor supported subset`
  - `Codec / decode boundary`
  - `Query / CRUD/live output domain`
  - `Query / .json() mode fidelity`
  - `API / ApiPromise.value and .json() state`
  - `Support / JsValue input helper surface`
- update made: the four release-blocker rows were closed and their evidence status raised to `strong`

## Residual Risk

- query results still depend on query text and remain a deliberate classified boundary
- event publisher callbacks remain value-dependent on the event string and stay flattened to `array<Surrealdb_Value.t>`
- codec encode/decode boundaries remain intentionally open at the foreign-data seam
- `ApiPromise.then_` remains a smaller fulfillment helper than the full upstream Promise overload set

## Verdict

- status:
  - acceptable with documented fidelity gaps
- reviewer: Codex
- date: 2026-04-23
