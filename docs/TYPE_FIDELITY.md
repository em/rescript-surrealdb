# Type Fidelity

## Purpose

This file records the deliberate gaps between upstream SurrealDB TypeScript expressivity and the current public ReScript surface.

The public `.resi` files stay authoritative. This file explains where the binding is intentionally narrower, more open, or package-added.

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
- Why: the callback tuple type depends on the runtime event key. ReScript cannot express one public function whose callback payload changes with the event string. The binding keeps the event name open and classifies each payload element through `Surrealdb_Value.fromUnknown`.

### Query result surface

- TS source: `node_modules/surrealdb/dist/surrealdb.d.ts`
  - `query<R extends unknown[] = unknown[]>(query: string, bindings?: Record<string, unknown>): Query<R>`
  - `query<R extends unknown[] = unknown[]>(query: BoundQuery<R>): Query<R>`
- ReScript representation:
  - `type result = array<Surrealdb_Value.t>`
  - text and bound query helpers in `Surrealdb_Query` resolve to `t<result>`, `promise<result>`, or `Surrealdb_AsyncIterable.t<Surrealdb_QueryFrame.t>`
- Why: the result shape depends on query text and caller intent. Exporting a free `'a` here would claim precision the runtime does not prove. The current surface keeps results as classified Surreal values until the caller narrows them further.

### `Surrealdb_Query.thenResolve`

- TS source: Promise-like `then(...)` overloads on the SDK `Query` class
- ReScript representation: `let thenResolve: (t<'value>, ('value => 'value)) => promise<'value>`
- Why: the current public binding exposes the common fulfillment path without attempting to compress the full Promise-like overload set into one broader public signature.

### `Surrealdb_ApiPromise.then_`

- TS source: `DispatchedPromise.then<TResult1 = T, TResult2 = never>(...)`
- ReScript representation: `let then_: (t<'value>, ('value => 'value)) => promise<'value>`
- Why: the public binding keeps the fulfillment-preserving path that the package uses directly and does not attempt to model the full Promise overload set as a bespoke public abstraction.

### `Surrealdb_RangeBound.included` / `excluded`

- TS source: `BoundIncluded<T>` and `BoundExcluded<T>`
- ReScript representation:
  - `let included: unknown => t`
  - `let excluded: unknown => t`
- Why: the upstream constructor accepts any runtime value, but ReScript cannot honestly preserve that value parameter as a public free type variable. The binding keeps the input open as `unknown` instead of exporting fake precision.

### Engine factory invocation

- TS source: `node_modules/surrealdb/dist/surrealdb.d.ts`
  - `type EngineFactory = (context: DriverContext) => SurrealEngine`
  - `type Engines = Record<string, EngineFactory>`
  - `createRemoteEngines(): Engines`
- ReScript representation:
  - `Surrealdb_RemoteEngines.factory` stays opaque
  - `Surrealdb_DriverContext.instantiate: (t, Surrealdb_RemoteEngines.factory) => Surrealdb_Engine.t`
- Why: the SDK returns a plain JS record of callable engine factories. The binding keeps those function values opaque and invokes them through a package helper so `DriverOptions`, `RemoteEngines`, and `DriverContext` do not create a public module cycle.

### Environment default WebSocket

- Upstream reality:
  - WebSocket availability is environment-dependent
  - the SDK can run in environments where the global `WebSocket` binding is absent or not the active transport path
- ReScript representation:
  - `Surrealdb_Surreal.defaultWebSocketImpl: option<Surrealdb_DriverOptions.websocketImpl>`
- Why: exporting a non-optional default value lies about environments such as Node 20 where no global `WebSocket` exists. The binding now keeps that boundary honest and leaves absence explicit.

### Codec decode boundary

- Public surface:
  - `Surrealdb_CborCodec.encode: (t, unknown) => Uint8Array.t`
  - `Surrealdb_CborCodec.decodeUnknown: (t, Uint8Array.t) => unknown`
  - `Surrealdb_CborCodec.decodeWith: (t, Uint8Array.t, unknown => option<'value>) => result<'value, decodeError>`
  - same shape in `Surrealdb_ValueCodec`
- Why: a codec can return foreign runtime data, but it cannot prove the final ReScript type by itself. The binding leaves the raw decode boundary open and requires a caller-supplied classifier for typed recovery.

### Raw RPC error builders

- Public surface:
  - `Surrealdb_ServerError.makeRpcErrorCause`
  - `Surrealdb_ServerError.makeRpcErrorObject`
  - both accept `~details: dict<unknown>=?`
- Why: these constructors mirror raw JSON-RPC error payload assembly. The read side is typed through `Surrealdb_ErrorPayload.t`, but the write side remains open because the upstream payload fields are not a closed Surreal value algebra.

### `Surrealdb_RecordId.idValue`

- Upstream runtime: `RecordId` stores several possible identifier shapes.
- ReScript representation:
  - `type idValue = StringId(string) | NumberId(float) | UuidId(Surrealdb_Uuid.t) | BigIntId(BigInt.t) | ArrayId(array<JSON.t>) | ObjectId(dict<JSON.t>)`
- Why: the binding exposes the current supported runtime identifier shapes as a package-owned union instead of returning raw `unknown`.

## Package-Added Surfaces

### `Surrealdb_Value.t`

- Upstream runtime: the SDK exports runtime classes such as `RecordId`, `DateTime`, `Duration`, `Decimal`, `Uuid`, `Table`, `Geometry`, `Range`, and plain JS primitives and containers.
- ReScript representation: `Surrealdb_Value.t` is a package classifier layered over those runtime values.
- Why: this package-added surface supports exhaustive matching across mixed runtime payloads. It is not a direct upstream SDK export and must stay documented as package-owned API.

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
- Why: these helpers are convenience layers around `query()` and `BoundQuery`. They remain public, but they must never be documented as if upstream `surrealdb` exports them directly.

### Engine factory helpers

- Package-added helpers:
  - `Surrealdb_DriverContext.instantiate`
  - `Surrealdb_RemoteEngines.keys`
- Why: the SDK exposes engines as a string-keyed record of function values. These helpers make that record usable from ReScript without claiming that the SDK exports named `instantiate` or `keys` methods.
