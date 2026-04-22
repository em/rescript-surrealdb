# Soundness Matrix

## Status

- Build: **PASSING** (`npm run build`, targeted boundary `vitest`, `npm test`, `npm pack --dry-run`)
- Current audits:
  - `docs/audits/bootstrap-soundness-repair.md`
  - `docs/audits/bootstrap-public-boundary-failures.md`
  - `docs/audits/connection-remote-engine-factory.md`
  - `docs/audits/environment-default-globals.md`
  - `docs/audits/public-boundary-tightening.md`

## Matrix

| Subsystem | Boundary | Risk | Source Files | Test Files | Audit File | Evidence Status | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Value | runtime class classification (`Value.fromUnknown`) | foreign values misclassified as Surreal values | `src/value/Surrealdb_Value.resi` | `tests/value/SurrealdbValueSurface_test.res`, `tests/value/SurrealdbBindingValue_test.res` | `docs/audits/public-boundary-tightening.md` | strong | direct tests now cover `NaN`, infinities, and int-range edges |
| Value | `RecordId.idValue` classification | raw id part misclassified | `src/value/Surrealdb_RecordId.resi` | `tests/value/SurrealdbValueSurface_test.res` | `docs/audits/bootstrap-soundness-repair.md` | partial | basic and compound id shapes are covered; deeper nested shapes can still drift |
| Value | `RangeBound` open input boundary | constructor could pretend to preserve caller type | `src/value/Surrealdb_RangeBound.resi` | `tests/value/SurrealdbValueSurface_test.res`, `tests/query/SurrealdbPublicSurface_test.res` | `docs/audits/public-boundary-tightening.md` | strong | public input is now explicitly `unknown` and round-tripped directly |
| Codec | decode boundary (`decodeWith`) | typed decode could be claimed without caller classification | `src/value/Surrealdb_CborCodec.resi`, `src/value/Surrealdb_ValueCodec.resi` | `tests/value/SurrealdbBindingValue_test.res` | `docs/audits/bootstrap-soundness-repair.md` | partial | checked decode is exercised; rejected-value branches are still limited |
| Errors | error hierarchy classification | errors misclassified across client/server/base | `src/errors/Surrealdb_ClientError.resi`, `src/errors/Surrealdb_ServerError.resi`, `src/errors/Surrealdb_SurrealError.resi` | `tests/errors/SurrealdbErrorSupport_test.res` | `docs/audits/bootstrap-soundness-repair.md` | strong | real SDK errors are constructed and classified directly |
| Errors | `ErrorPayload` classification | unknown payloads collapsed into fake closed values | `src/errors/Surrealdb_ErrorPayload.resi` | `tests/errors/SurrealdbErrorPayloadSurface_test.res` | `docs/audits/bootstrap-soundness-repair.md` | strong | arrays, dicts, nested values, and recursive payloads are covered |
| Errors | `ClientError.asXxx` unknown boundary | non-errors downcast as client errors | `src/errors/Surrealdb_ClientError.resi` | `tests/errors/SurrealdbErrorSupport_test.res` | `docs/audits/public-boundary-tightening.md` | strong | classifiers now accept `unknown` and reject non-errors directly |
| Query | dynamic result boundary | query result shape treated as stronger than runtime proves | `src/query/Surrealdb_Query.resi`, `src/query/Surrealdb_QueryResponse.resi` | `tests/connection/SurrealdbSessionSurface_test.res` | `docs/audits/bootstrap-public-boundary-failures.md` | partial | real server execution is covered; result semantics still depend on query text |
| Query | query frame classification | raw frames drift from typed accessors | `src/query/Surrealdb_QueryFrame.resi` | `tests/connection/SurrealdbSessionSurface_test.res`, `tests/query/SurrealdbPublicSurface_test.res` | `docs/audits/bootstrap-public-boundary-failures.md` | partial | stream frames and classifier rejection are covered; exhaustive frame-shape probes are still limited |
| Live | event payload boundary | value-dependent event tuples flattened | `src/live/Surrealdb_Publisher.resi`, `src/connection/Surrealdb_Session.resi`, `src/live/Surrealdb_LiveMessage.resi` | `tests/live/SurrealdbStreamUtility_test.res`, `tests/connection/SurrealdbSessionSurface_test.res` | `docs/audits/public-boundary-tightening.md` | partial | publisher tuples and managed/unmanaged `LiveMessage.value` classification are now tested directly |
| Live | `Frame.fromUnknown` open classifier | arbitrary payload type could be manufactured from `instanceof` | `src/live/Surrealdb_Frame.resi` | `tests/query/SurrealdbPublicSurface_test.res` | `docs/audits/public-boundary-tightening.md` | strong | public return is now `option<t<unknown>>` and rejection cases are tested |
| Connection | session lifecycle and auth | auth/session APIs drift from installed SDK | `src/connection/Surrealdb_Surreal.resi`, `src/connection/Surrealdb_Session.resi` | `tests/connection/SurrealdbSessionSurface_test.res` | `docs/audits/bootstrap-soundness-repair.md` | strong | full lifecycle exercised against a real server |
| Connection | remote engine factory invocation | helper drift widens factory or diagnostics boundaries | `src/connection/Surrealdb_DriverContext.resi`, `src/connection/Surrealdb_RemoteEngines.resi` | `tests/query/SurrealdbPublicSurface_test.res`, `tests/connection/SurrealdbSessionSurface_test.res` | `docs/audits/connection-remote-engine-factory.md` | strong | factory stays opaque and diagnostics stay classified |
| Connection | engine subtype casts | engine downcast could drift if SDK hierarchy changes | `src/connection/Surrealdb_HttpEngine.resi`, `src/connection/Surrealdb_WebSocketEngine.resi`, `src/connection/Surrealdb_RpcEngine.resi` | `tests/query/SurrealdbPublicSurface_test.res` | `docs/audits/public-boundary-tightening.md` | strong | ws/http instantiation is classified directly through the public `fromEngine` APIs |
| Connection | default transport globals | eager global access can lie about environment capabilities or crash module load | `src/connection/Surrealdb_Surreal.resi`, `src/support/Surrealdb_Interop.js` | `tests/query/SurrealdbPublicSurface_test.res` | `docs/audits/environment-default-globals.md` | strong | `defaultWebSocketImpl` is now optional and the module imports cleanly when `globalThis.WebSocket` is absent |
| API | optional response fields | absent body/status/headers could manufacture values | `src/api/Surrealdb_ApiResponse.resi` | `tests/connection/SurrealdbSessionSurface_test.res` | `docs/audits/public-boundary-tightening.md` | strong | direct object-boundary tests cover omitted, nullish, and present fields |
| API | `ApiPromise.then_` fulfillment helper | callback could receive a value inconsistent with the promise surface | `src/api/Surrealdb_ApiPromise.resi` | `tests/connection/SurrealdbSessionSurface_test.res` | `docs/audits/public-boundary-tightening.md` | strong | direct test verifies the fulfillment callback receives `ApiResponse.t` on the installed SDK |
| Support | `Jsonify` unknown-to-JSON cast | SDK may return a non-JSON value | `src/support/Surrealdb_Jsonify.resi` | `tests/query/SurrealdbPublicSurface_test.res` | `docs/audits/public-boundary-tightening.md` | strong | nested SDK values are stringified and parsed back as valid JSON |
| Export/Helpers | package-authored helper surface | helpers drift from documented non-upstream status | `src/query/Surrealdb_Export.resi`, `src/query/Surrealdb_Query.resi`, `src/connection/Surrealdb_DriverContext.resi` | `tests/query/SurrealdbPublicSurface_test.res`, `tests/connection/SurrealdbSessionSurface_test.res` | `docs/audits/connection-remote-engine-factory.md` | partial | helper behavior is tested and documented; drift remains a documentation-maintenance risk |

## Evidence Status Key

- `strong` -- direct test that would fail if the binding lied about the boundary
- `partial` -- test exists, but value-dependent or drift-oriented risk remains
