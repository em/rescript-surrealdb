# TYPE_FIDELITY

## Compromises

### `Surrealdb_Session.subscribe`
- TS source: `surrealdb.d.ts`, `SurrealSession.subscribe<K extends keyof SessionEvents>(event: K, listener: (...payload: SessionEvents[K]) => void): () => void`
- ReScript representation: `(t, string, array<unknown> => unit) => unit => unit`
- Why: the payload type is selected by the event string key and then expands into variadic tuples. ReScript can bind the callable surface, but not the full keyed variadic event map without splitting every event into separate functions.

### `Surrealdb_Surreal.subscribe`
- TS source: `surrealdb.d.ts`, `Surreal.subscribe<K extends keyof SurrealEvents>(event: K, listener: (...payload: SurrealEvents[K]) => void): () => void`
- ReScript representation: `(t, string, array<unknown> => unit) => unit => unit`
- Why: same keyed variadic event-map limitation as `SurrealSession.subscribe`.

### `Surrealdb_Publisher.subscribe`
- TS source: `surrealdb.d.ts`, `Publisher<T extends EventPayload>.subscribe<K extends keyof T>(event: K, listener: (...payload: T[K]) => void): () => void`
- ReScript representation: `(t, string, array<unknown> => unit) => unit => unit`
- Why: generic event maps with event-selected variadic payload tuples are narrower in TypeScript than ReScript can represent directly in one public function.

### `Surrealdb_Query.t<'value>`
- TS source: `surrealdb.d.ts`, `query<R extends unknown[] = unknown[]>(query: string | BoundQuery<R>): Query<R>`
- ReScript representation: statement constructors in `Surrealdb_Query` currently center on `array<unknown>` for dynamic query result tuples
- Why: result tuple shape depends on statement text and generic instantiation at each call site. The current binding keeps the runtime surface honest and pushes precise result narrowing to the caller.

### `Surrealdb_Value.t`
- TS source: public SurrealDB JS SDK runtime classes such as `RecordId`, `DateTime`, `Duration`, `Decimal`, `Uuid`, `Table`, `Geometry`, `Range`, plus plain JS primitives and containers
- ReScript representation: a closed recursive `Surrealdb_Value.t` classifier layered over the SDK runtime values
- Why: the package preserves the typed SDK class bindings directly, but it also carries a retained classifier helper from the reference project for exhaustive pattern matching across mixed runtime values. This is package-added surface, not a direct SDK export.

### `Surrealdb_Query` helper constructors
- TS source: `surrealdb.d.ts`, `SurrealQueryable.query()` and `BoundQuery`
- ReScript representation: helper APIs such as `runText`, `runBound`, `statement`, `databaseInfoStatement`, `tableInfoStatement`, `countAllStatement`, and `dbStructureStatement`
- Why: these are convenience helpers retained from the reference project around the real `query()` / `BoundQuery` surface. They are not direct SDK exports and should be treated as package-level helper surface.

### `Surrealdb_Query.thenResolve`
- TS source: `Query.then(...)` inherited Promise-like fulfillment / rejection overloads on the SDK `Query` class
- ReScript representation: `(t<'value>, ('value => 'value)) => promise<'value>`
- Why: the current binding exposes the common fulfillment path and does not model the broader Promise-like overload set in one public signature.
