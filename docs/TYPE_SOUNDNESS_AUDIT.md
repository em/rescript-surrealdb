# Type Soundness Audit

## Build Status

**BUILD PASSING. TEST GATE PASSING.**

Verification run on 2026-04-25:

- `npm run build`
- `npm test`
  - all 22 Vitest files passed
  - all 85 Vitest tests passed
  - enforced global coverage gate passed:
    - 83.16% statements
    - 91.18% branches
    - 80.25% functions
    - 83.16% lines

Build health is necessary and insufficient. The current soundness verdict also depends on direct boundary tests and direct runtime probes inside this repo.

## Inventory

| Metric | Count |
|--------|-------|
| Public `unknown` lines in `.resi` files | 121 |
| `%identity` in `.res` files | 218 |
| `Obj.magic` | 0 |
| `%raw` | 0 |
| Public `*Raw` APIs | 61 |

## `%identity` Summary

The remaining `%identity` sites fall into four accepted classes:

- checked runtime casts after `instanceof`, `typeof`, or nullable checks
- honest subtype upcasts for real SDK inheritance
- explicit widening into `unknown` at foreign boundaries
- internal boundary sealing for opaque boundary modules and union simulation

No current public `%identity` site manufactures a more precise public type than the runtime proved.

## Corrected on 2026-04-23

1. Promise builders no longer leak input-side `Surrealdb_JsValue.t` into resolved output positions.
   - CRUD builders and `Auth` now resolve to `Surrealdb_Value.t` on the ordinary path and `JSON.t` after `.json()`.
   - `Query` now resolves to `array<Surrealdb_Value.t>` or `array<JSON.t>`.
   - `Live` no longer exports a fake payload generic.

2. `.json()` mode is now explicit in the public type system.
   - `Query`, CRUD builders, `Auth`, and `ApiPromise` all change public format state at the type level.

3. `ApiPromise` now models the real upstream type-state more honestly.
   - response-envelope/body mode is separate from value/JSON mode
   - `stream()` remains envelope-only because the installed runtime does not expose a body-mode stream

4. `RangeBound` constructor input is now a closed recursive supported subset.
   - the typed constructor path no longer requires `unknown`
   - the readback classifier still exposes broader foreign runtime leaves through `Surrealdb_BoundValue.t`

5. `RecordId.idValue` no longer projects compound ids through JSON.
   - compound ids use a recursive `component` algebra
   - unsupported nested leaves remain explicit through `option<idValue>`

6. Public boundary tests no longer depend only on package-local cast functions.
   - direct repo tests must exercise the public call shape itself
   - package-local `%identity` cast functions do not count as proof for the typed path

## Intentional Public Open Boundaries

### Query and templating inputs

- `Surrealdb_BoundQuery.appendTemplate`
- `Surrealdb_Surql.*`
- `Surrealdb_Expr.*`

### Runtime classification inputs

- `fromUnknown` and `isInstance` classifiers across value, frame, feature, and error modules
- `Surrealdb_ClientError.asXxx`

### Codec and raw transport boundaries

- `Surrealdb_CborCodec.encode`, `decodeUnknown`, `decodeWith`
- `Surrealdb_ValueCodec.encode`, `decodeUnknown`, `decodeWith`
- `Surrealdb_ServerError.makeRpcErrorCause` / `makeRpcErrorObject`

### Why these remain open

- query text, event names, codec payloads, and raw server error details are value-dependent at runtime
- a closed ReScript type at those boundaries would over-claim what the installed SDK actually proves

## Coverage Status

- direct tests now cover the builder output-domain redesign, explicit `.json()` state transitions, `RangeBound`, `RecordId.idValue`, `Jsonify`, API optional fields, `ApiPromise.then_`, and live message value classification
- direct repo tests cover:
  - query/auth typed-path behavior
  - `JsValue` typed input APIs
  - `RangeBound` supported constructor input
  - `RecordId.idValue` supported subset and unsupported remainder
  - `CborCodec` and `ValueCodec` decode boundaries
  - narrowed timeout and `health` public contract
  - explicit raw query-text `TIMEOUT` runtime behavior on the exercised server

## Residual Risk

- query results remain value-dependent on query text and stay intentionally classified rather than schema-typed
- event publisher callbacks remain flattened to `array<Surrealdb_Value.t>` because the payload tuple depends on the runtime event string
- codec boundaries remain intentionally open at the foreign-data seam
- `ApiPromise.then_` remains narrower than the full upstream Promise overload family
- timeout builder methods are intentionally absent from the public binding surface until the upstream runtime defect is closed
- `health()` is intentionally absent from the public `ws/rpc` binding surface until a supported runtime path exists

## Verdict

The timeout and `health()` runtime-support blockers are closed by narrowing the public contract.

The current repo-owned validation verdict is green because `npm run build` and `npm test` both pass, and the enforced global 80% coverage threshold is now satisfied. The remaining fidelity gaps above stay documented as intentional open boundaries or narrower supported subsets rather than open release blockers.
