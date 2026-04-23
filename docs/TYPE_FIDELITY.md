# Type Fidelity

## Purpose

This file records the deliberate gaps between upstream SurrealDB TypeScript expressivity and the current public ReScript surface.

The public `.resi` files stay authoritative. This file explains where the binding is intentionally narrower, more open, package-added, or intentionally unsupported because widening the whole surface would damage soundness.

Each entry states:

- the strict supported subset
- the unsupported or still-open upstream remainder
- why a wider public ReScript type would lie

## Fidelity Gaps

### Event publisher callbacks

- TS source: `node_modules/surrealdb/dist/surrealdb.d.ts`
  - `Publisher.subscribe<K extends keyof T>(event: K, listener: (...event: T[K]) => void): () => void`
  - `SurrealSession.subscribe<K extends keyof SessionEvents>(event: K, listener: (...payload: SessionEvents[K]) => void): () => void`
  - `Surreal.subscribe<K extends keyof SurrealEvents>(event: K, listener: (...payload: SurrealEvents[K]) => void): () => void`
- ReScript representation:
  - `Surrealdb_Publisher.subscribe: (t, string, array<Surrealdb_Value.t> => unit) => unit => unit`
  - `Surrealdb_Session.subscribe: (t, string, array<Surrealdb_Value.t> => unit) => unit => unit`
  - `Surrealdb_Surreal.subscribe: (t, string, array<Surrealdb_Value.t> => unit) => unit => unit`
- Strict supported subset:
  - runtime event name plus classified payload elements
- Unsupported remainder:
  - a single public callback type whose payload tuple changes with the runtime event string
- Why: the callback tuple type depends on the runtime event key. ReScript cannot express that value-dependent public function shape honestly.

### Query result surface

- TS source: `node_modules/surrealdb/dist/surrealdb.d.ts`
  - `query<R extends unknown[] = unknown[]>(...) => Query<R>`
- ReScript representation:
  - `type result = array<Surrealdb_Value.t>`
  - `type jsonResult = array<JSON.t>`
  - `Surrealdb_Query` resolves or streams those classified arrays
- Strict supported subset:
  - classified Surreal values on the ordinary path
  - explicit JSON values after `.json()`
- Unsupported remainder:
  - exact static tuple typing derived from query text or caller convention
- Why: the result shape depends on query text and caller intent. Exporting a free `'a` here would claim precision the runtime does not prove.

### CRUD, auth, live, and API resolved output typing

- TS source:
  - `auth<T>(): AuthPromise<RecordResult<T> | undefined>`
  - `select<T>(...): SelectPromise<RecordResult<T> | undefined | RecordResult<T>[], T>`
  - `create<T>(...): CreatePromise<RecordResult<T> | RecordResult<T>[], T>`
  - `update<T>(...): UpdatePromise<RecordResult<T> | RecordResult<T>[], T>`
  - `upsert<T>(...): UpsertPromise<RecordResult<T> | RecordResult<T>[], T>`
  - `delete<T>(...): DeletePromise<RecordResult<T> | RecordResult<T>[]>`
  - `insert<T>(...): InsertPromise<RecordResult<T>[]>`
  - `relate<T>(...): RelatePromise<T | T[]>`
  - `run<T>(...): RunPromise<T>`
  - `class ApiPromise<Req, Res, V extends boolean = false, J extends boolean = false>`
- ReScript representation:
  - CRUD builders and `Auth` resolve to `Surrealdb_Value.t` on the ordinary path and `JSON.t` after `.json()`
  - `Query` resolves to `array<Surrealdb_Value.t>` or `array<JSON.t>`
  - `Live` resolves to `Surrealdb_LiveSubscription.t`
  - `ApiPromise` resolves to `Surrealdb_ApiResponse.t`, `Surrealdb_ApiJsonResponse.t`, `Surrealdb_Value.t`, or `JSON.t` depending on explicit mode
- Strict supported subset:
  - builder configuration
  - compile
  - execution on classified outputs
  - explicit response/body and value/JSON mode transitions
- Unsupported remainder:
  - exact static modeling of caller-supplied schema types or query-text-derived record shapes as ordinary ML polymorphism
- Why: the upstream generic `T` is intent- or schema-driven rather than runtime-preserved ML polymorphism. The strongest honest public shape is classified output plus explicit mode state.

### Promise `.json()` state on query/auth/CRUD/API builders

- TS source:
  - `json(): Query<R, true>`
  - `json(): SelectPromise<T, I, true>`
  - `json(): CreatePromise<T, I, true>`
  - `json(): UpdatePromise<T, I, true>`
  - `json(): UpsertPromise<T, I, true>`
  - `json(): DeletePromise<T, true>`
  - `json(): InsertPromise<T, true>`
  - `json(): RelatePromise<T, true>`
  - `json(): RunPromise<T, true>`
  - `json(): AuthPromise<T, true>`
  - `json(): ApiPromise<Req, Res, V, true>`
- ReScript representation:
  - `Query.json: t<'value> => t<jsonResult>`
  - CRUD and `Auth`: `json: t<'value> => t<JSON.t>`
  - `ApiPromise.json: t<'mode, valueFormat> => t<'mode, jsonFormat>`
- Strict supported subset:
  - explicit format-state transition at the public type level
  - direct typed access to JSONified results and frames where the runtime exposes them
- Unsupported remainder:
  - exact `MaybeJsonify<T, J>` propagation for caller-defined `T`
- Why: upstream tracks a real JSON-mode state. The binding models that state explicitly, but it does not pretend it can preserve arbitrary caller-defined schema types through that transition.

### Promise-builder timeout helpers

- Upstream runtime currently observed:
  - the installed SDK path compiles timeout clauses as `TIMEOUT TIMEOUT 5s` on the exercised query builders
- ReScript representation:
  - `timeout` helpers are exposed across CRUD/select/relate builders
- Strict supported subset:
  - none proven yet for the currently exercised SQL-compiling path
- Unsupported remainder:
  - any package claim that `timeout()` is a correct, supported helper on those builders until the runtime defect is closed
- Why: the package must not treat a helper as sound just because it forwards to the upstream method. A forwarded helper that deterministically emits broken query text is still a broken public package surface.

### `Surrealdb_Surreal.health` on `ws/rpc`

- Upstream runtime currently observed:
  - `health()` over the exercised `ws://127.0.0.1:8787/rpc` path returns `Method not found`
- ReScript representation:
  - `Surrealdb_Surreal.health: t => promise<unit>`
  - `Surrealdb_RpcEngine.health: t => promise<unit>`
- Strict supported subset:
  - no successful `ws/rpc` health contract is currently proved
- Unsupported remainder:
  - any package claim that `health()` is a supported readiness probe on the exercised `ws/rpc` path until runtime proof exists
- Why: a public binding cannot call this a healthy supported surface while its own direct runtime probe only proves failure on the transport path the consumer actually uses.

### `ApiPromise.stream()` and `value()`

- Upstream runtime:
  - `value()` changes fulfillment mode
  - `stream()` still yields response envelopes on the installed SDK
- ReScript representation:
  - `stream: t<'mode, valueFormat> => AsyncIterable.t<Frame.t<ApiResponse.t>>`
  - `streamJson: t<'mode, jsonFormat> => AsyncIterable.t<Frame.t<ApiJsonResponse.t>>`
  - there is no body-mode stream API
- Why: the installed runtime does not expose a distinct body-mode stream surface. Exporting one would lie.

### `Surrealdb_Query.thenResolve` and `Surrealdb_ApiPromise.then_`

- TS source: Promise-like `then(...)` overloads on SDK builder classes
- ReScript representation:
  - fulfillment-preserving helpers only
- Strict supported subset:
  - the ordinary fulfillment path used by the package surface
- Unsupported remainder:
  - the full upstream Promise overload family as a bespoke public abstraction
- Why: the binding keeps the common sound fulfillment path and documents the rest as a fidelity gap instead of inventing a misleading Promise façade.

### `Surrealdb_RangeBound.included` / `excluded`

- TS source:
  - `class BoundIncluded<T> { readonly value: T }`
  - `class BoundExcluded<T> { readonly value: T }`
- ReScript representation:
  - constructor input:
    - `Undefined | Null | Bool | Int | Float | String | BigInt | ValueClass | Array | Object`
  - readback:
    - `value: t => Surrealdb_BoundValue.t`
- Strict supported subset:
  - recursive constructor inputs that the package can re-emit exactly
- Unsupported remainder:
  - constructor input through arbitrary foreign `unknown`
  - function and symbol leaves on the typed constructor path
- Why: the package can model the supported recursive subset directly. Reopening the constructor to `unknown` would reintroduce consumer friction, and pretending every `BoundValue.t` is constructible would over-claim.

### Engine factory invocation

- TS source: `EngineFactory = (context: DriverContext) => SurrealEngine`
- ReScript representation:
  - `Surrealdb_RemoteEngines.factory` stays opaque
  - `Surrealdb_DriverContext.instantiate` invokes one opaque factory with a typed context
- Why: the SDK returns a plain JS record of function values. The helper keeps the public graph acyclic without pretending the SDK exports a named `instantiate` method.

### Environment default WebSocket

- Upstream reality:
  - WebSocket availability is environment-dependent
- ReScript representation:
  - `Surrealdb_Surreal.defaultWebSocketImpl: option<Surrealdb_DriverOptions.websocketImpl>`
- Why: exporting a non-optional default value would lie about environments such as Node 20 where no global `WebSocket` exists.

### Codec decode boundary

- Public surface:
  - `Surrealdb_CborCodec.encode: (t, unknown) => Uint8Array.t`
  - `Surrealdb_CborCodec.decodeUnknown: (t, Uint8Array.t) => unknown`
  - `Surrealdb_CborCodec.decodeWith: (t, Uint8Array.t, unknown => option<'value>) => result<'value, decodeError>`
  - same shape in `Surrealdb_ValueCodec`
- Strict supported subset:
  - explicit caller-supplied classification at the decode seam
- Unsupported remainder:
  - package-chosen final `'value` without caller evidence
- Why: the codec can return foreign runtime data, but it cannot prove the final ReScript type by itself.

### Raw RPC error builders

- Public surface:
  - `Surrealdb_ServerError.makeRpcErrorCause`
  - `Surrealdb_ServerError.makeRpcErrorObject`
  - both accept `~details: dict<unknown>=?`
- Why: these constructors mirror raw JSON-RPC error payload assembly. The read side is typed through `Surrealdb_ErrorPayload.t`, but the write side remains open because the upstream payload fields are not a closed Surreal value algebra.

### `Surrealdb_RecordId.idValue`

- Upstream runtime:
  - `RecordId` stores `string | number | Uuid | bigint | unknown[] | Record<string, unknown>`
- ReScript representation:
  - `type rec component = Undefined | Null | Bool | Int | Float | String | BigInt | ValueClass | Array | Object`
  - `type idValue = StringId | NumberId | UuidId | BigIntId | ArrayId | ObjectId`
  - `idValue: t => option<idValue>`
- Strict supported subset:
  - scalar ids
  - compound ids whose nested leaves fit the recursive `component` subset
  - nested value-class leaves such as `DateTime`, `Duration`, `Decimal`, `Uuid`, `Table`, `Range`, `Geometry`, and `RecordId`
- Unsupported remainder:
  - nested leaves that cannot be reclassified into `component`, including nested function and symbol cases
- Why: the package now models the supported recursive subset directly. Returning `None` for the unsupported remainder is narrower and more honest than flattening the whole boundary to JSON or `unknown`.

## Package-Added Surfaces

### `Surrealdb_Value.t`

- Upstream runtime: the SDK exports runtime classes such as `RecordId`, `DateTime`, `Duration`, `Decimal`, `Uuid`, `Table`, `Geometry`, `Range`, and plain JS primitives and containers
- ReScript representation: `Surrealdb_Value.t` is a package classifier layered over those runtime values
- Why: this package-added surface supports exhaustive matching across mixed runtime payloads. It is not a direct upstream SDK export and stays documented as package-owned API.

### `Surrealdb_Query` helper constructors

- Package-added helpers:
  - `runTextOn`
  - `runText`
  - `runBoundOn`
  - `runBound`
  - `statement`
  - `databaseInfoStatement`
  - `tableInfoStatement`
  - `countAllStatement`
  - `tableStructureStatement`
  - `dbStructureStatement`
- Why: these helpers are convenience layers around `query()` and `BoundQuery`. They remain public, but they are not documented as upstream SDK exports.

### Engine factory helpers

- Package-added helpers:
  - `Surrealdb_DriverContext.instantiate`
  - `Surrealdb_RemoteEngines.keys`
- Why: the SDK exposes engines as a string-keyed record of function values. These helpers make that record usable from ReScript without claiming the SDK exports named `instantiate` or `keys` methods.
