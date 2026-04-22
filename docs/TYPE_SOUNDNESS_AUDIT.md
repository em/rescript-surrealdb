# Type Soundness Audit

## Build Status

**BUILD PASSING.** `npm run build`, targeted `vitest` for value/query/session boundaries, `npm test`, and `npm pack --dry-run` all passed on 2026-04-22 after the public-boundary tightening pass.

## Inventory

| Metric | Count |
|--------|-------|
| Public `unknown` lines in `.resi` files | 122 |
| `%identity` in `.res` files | 163 |
| `Obj.magic` | 0 |
| `%raw` | 0 |
| Public `*Raw` APIs | 66 |

## `%identity` Breakdown

163 total. Categorized:

### Checked runtime casts (safe -- guarded by `instanceof` or `typeof`)

- `Surrealdb_Value.res`: 8 casts in `fromUnknown`
- `Surrealdb_BoundValue.res`: 8 casts
- `Surrealdb_ErrorPayload.res`: 6 casts
- `Surrealdb_ClientError.res`: 24 casts
- `Surrealdb_ServerError.res`: 12 casts
- `Surrealdb_SurrealError.res`: 1 cast
- `Surrealdb_Feature.res`: 1 cast
- `Surrealdb_Frame.res`: 5 casts
- `Surrealdb_ManagedLiveSubscription.res`: 1 cast
- `Surrealdb_UnmanagedLiveSubscription.res`: 1 cast
- `Surrealdb_HttpEngine.res`: 1 cast
- `Surrealdb_WebSocketEngine.res`: 1 cast
- `Surrealdb_RpcEngine.res`: 1 cast
- `Surrealdb_RecordId.res`: 6 casts for `idValue`
- Value type classifiers (DateTime, Uuid, Decimal, Duration, Table, FileRef, Future, 7 geometry types, StringRecordId): 16 casts

### Honest subtype upcasts (safe -- runtime IS-A relationships)

- `Surrealdb_Surreal.res`: `asQueryable`, `asSession`
- `Surrealdb_Session.res`: `asQueryable`
- `Surrealdb_Transaction.res`: `asQueryable`
- `Surrealdb_HttpEngine.res`: `asEngine`
- `Surrealdb_WebSocketEngine.res`: `asEngine`
- `Surrealdb_RpcEngine.res`: `asEngine`
- `Surrealdb_ManagedLiveSubscription.res`: `asLiveSubscription`
- `Surrealdb_UnmanagedLiveSubscription.res`: `asLiveSubscription`
- `Surrealdb_ChannelIterator.res`: `asAsyncIterable`
- `Surrealdb_ValueCodec.res`: `fromCborCodec`
- 7 geometry types: `asGeometry`

### Explicit boundary conversions into `unknown` (safe -- widening)

- `toUnknown` in `Surrealdb_Error.res`, `Surrealdb_Frame.res`, `Surrealdb_RangeBound.res`
- `Surrealdb_Escape.res`: `boundToUnknown`
- `Surrealdb_Export.res`: `unsafeBoolToUnknown`, `unsafeArrayToUnknown`
- `Surrealdb_JsValue.res`: internal `unsafeFrom`

### Union simulation and boundary sealing

- `Surrealdb_Surreal.res`: connect/auth/input union helpers
- `Surrealdb_Session.res`: `accessRecordAsSignin`
- `Surrealdb_RemoteEngines.res`: `asDict`
- `Surrealdb_QueryFrame.res`: sealing `Frame.t<unknown>` into opaque `QueryFrame.t`
- `Surrealdb_Query.res`: `asQueryFrameStream`

### Geometry `toJSON` recovery

- 7 geometry modules: `unsafeJsonFromUnknown` assume SDK GeoJSON output is valid JSON

## Corrected Since Bootstrap

1. `Surrealdb_ClientError.asXxx` no longer accepts fake polymorphic `'a`. The public classifiers now accept `unknown`, and direct tests verify that real SDK errors classify while non-errors are rejected.

2. `Surrealdb_RangeBound.included` and `excluded` no longer pretend to preserve a caller type variable. The public input is now explicitly open as `unknown`.

3. `Surrealdb_Frame.fromUnknown` no longer allows callers to manufacture an arbitrary payload type through an `instanceof` check. It now returns `option<t<unknown>>`.

4. `Surrealdb_DriverOptions.makeRaw` and `Surrealdb_DriverContext.makeRawInternal` no longer leave `engines` or `options` unconstrained at the object-construction boundary.

5. `Surrealdb_Value.fromUnknown` now classifies `-2147483648.0` as `Int`, and the public value tests now cover `NaN`, `Infinity`, negative infinity, and large-number boundaries directly.

6. Direct tests now cover `LiveMessage.value`, `Jsonify.value`, `ApiResponse` optional fields, `ApiPromise.then_`, engine subtype casts, and the `Frame.fromUnknown` classifier.

## Intentional Public Open Boundaries

### Query and templating inputs

- `Surrealdb_BoundQuery.appendTemplate`
- `Surrealdb_Surql.*`
- `Surrealdb_Expr.*`

### Runtime classification inputs

- `fromUnknown` and `isInstance` classifiers across value, frame, feature, and error modules
- `Surrealdb_ClientError.asXxx`
- `Surrealdb_RangeBound.included` / `excluded`

### Codec and raw transport boundaries

- `Surrealdb_CborCodec.encode`, `decodeUnknown`, `decodeWith`
- `Surrealdb_ValueCodec.encode`, `decodeUnknown`, `decodeWith`
- `Surrealdb_ServerError.makeRpcErrorCause` / `makeRpcErrorObject`

### Why these remain open

- Query text, event names, codec payloads, and raw server error details are value-dependent at runtime.
- A closed ReScript type at those boundaries would over-claim what the installed SDK actually proves.

## Coverage Status

- Direct tests now exist for every boundary that had been marked `weak` or `missing` in `docs/SOUNDNESS_MATRIX.md`.
- Remaining rows are intentionally `strong` or `partial`.
- The remaining `partial` rows are value-dependent or documentation-drift risks rather than unchecked downcasts.

## Residual Risk

- Query result semantics are still value-dependent on query text and remain partially provable.
- `RecordId.idValue` compound shapes and codec rejected-value branches still have only partial coverage.
- Event publishers still flatten value-dependent tuples to `array<Surrealdb_Value.t>` by design and stay documented in `docs/TYPE_FIDELITY.md`.

