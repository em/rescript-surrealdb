# Type Soundness Audit

## Build Status

**BUILD PASSING.**

Verification run on 2026-04-23:

- `npm run build`
- `npm test`
- `npm pack --dry-run`

Build health is necessary and insufficient. The current soundness verdict also depends on direct boundary tests and the packed-artifact clean-consumer proof in `scripts/packedConsumerProof.mjs`.

## Inventory

| Metric | Count |
|--------|-------|
| Public `unknown` lines in `.resi` files | 121 |
| `%identity` in `.res` files | 208 |
| `Obj.magic` | 0 |
| `%raw` | 0 |
| Public `*Raw` APIs | 68 |

## `%identity` Summary

The remaining `%identity` sites fall into four accepted classes:

- checked runtime casts after `instanceof`, `typeof`, or nullable checks
- honest subtype upcasts for real SDK inheritance
- explicit widening into `unknown` at foreign boundaries
- internal boundary sealing for opaque wrappers and union simulation

No current public `%identity` site manufactures a more precise public type than the runtime proved.

## Corrected on 2026-04-23

1. Promise builders no longer leak input-side `Surrealdb_JsValue.t` into resolved output positions.
   - CRUD builders and `Auth` now resolve to `Surrealdb_Value.t` on the ordinary path and `JSON.t` after `.json()`.
   - `Query` now resolves to `array<Surrealdb_Value.t>` or `array<JSON.t>`.
   - `Live` no longer exports a fake payload generic.

2. `.json()` mode is now explicit in the public type system.
   - `Query`, CRUD builders, `Auth`, and `ApiPromise` all change public format state at the type level.

3. `ApiPromise` now models the real upstream state machine more honestly.
   - response-envelope/body mode is separate from value/JSON mode
   - `stream()` remains envelope-only because the installed runtime does not expose a body-mode stream

4. `RangeBound` constructor input is now a closed recursive supported subset.
   - the typed constructor path no longer requires `unknown`
   - the readback classifier still exposes broader foreign runtime leaves through `Surrealdb_BoundValue.t`

5. `RecordId.idValue` no longer projects compound ids through JSON.
   - compound ids use a recursive `component` algebra
   - unsupported nested leaves remain explicit through `option<idValue>`

6. Public consumer proof no longer depends only on package-local cast helpers.
   - `scripts/packedConsumerProof.mjs` installs the packed tarball into a clean ReScript consumer
   - the consumer compiles and runs runtime checks against the published package surface

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
- the packed-consumer proof covers:
  - query/auth typed-path compilation
  - `JsValue` typed input helpers
  - `RangeBound` supported constructor input
  - `RecordId.idValue` supported subset and unsupported remainder
  - `CborCodec` and `ValueCodec` decode boundaries

## Residual Risk

- query results remain value-dependent on query text and stay intentionally classified rather than schema-typed
- event publisher callbacks remain flattened to `array<Surrealdb_Value.t>` because the payload tuple depends on the runtime event string
- codec boundaries remain intentionally open at the foreign-data seam
- `ApiPromise.then_` remains narrower than the full upstream Promise overload family
- timeout helper surfaces are currently release-blocked because direct tests still prove broken `TIMEOUT TIMEOUT` SQL on exercised builders
- `health()` is currently release-blocked on the exercised `ws/rpc` path because direct runtime proof still yields `Method not found`

## Verdict

The 2026-04-23 blocker line is no longer the full release verdict.

Current remaining fidelity gaps are documented, but the package also has reopened runtime-support blockers in `docs/RELEASE_BLOCKERS.md`. A green build and green tests are not sufficient while those blockers remain open.
