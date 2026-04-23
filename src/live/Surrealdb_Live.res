// src/bindings/Surrealdb_Live.res — SurrealDB live query binding.
// Concern: bind live-query builders without exporting a fake record payload
// generic that the runtime never proves.
// Source: surrealdb.d.ts — ManagedLivePromise<T> only resolves to LiveSubscription;
// payload typing lives on each emitted LiveMessage instead.
// Boundary: managed builder configuration is typed, while live message payloads
// are classified at `Surrealdb_LiveMessage.value`.
// Why this shape: the builder resolves only to `LiveSubscription`. Payload
// classification happens later on each emitted `LiveMessage`.
// Coverage: tests/connection/SurrealdbSessionSurface_test.res exercises managed
// and unmanaged live subscription behavior.
type managed
type unmanaged

@send external tableOn: (Surrealdb_Queryable.t, Surrealdb_Table.t) => managed = "live"
@send external ofOn: (Surrealdb_Queryable.t, Surrealdb_Uuid.t) => unmanaged = "liveOf"

@send external diff: managed => managed = "diff"
@send @variadic external fields: (managed, array<string>) => managed = "fields"
@send external value: (managed, string) => managed = "value"
@send external where: (managed, Surrealdb_Expr.t) => managed = "where"
@send @variadic external fetch: (managed, array<string>) => managed = "fetch"
@send external compile: managed => Surrealdb_BoundQuery.t = "compile"

@send
external thenManaged: (
  managed,
  @uncurry (Surrealdb_LiveSubscription.t => Surrealdb_LiveSubscription.t),
) => promise<Surrealdb_LiveSubscription.t> = "then"

@send
external thenUnmanaged: (
  unmanaged,
  @uncurry (Surrealdb_LiveSubscription.t => Surrealdb_LiveSubscription.t),
) => promise<Surrealdb_LiveSubscription.t> = "then"

let tableNamedOn = (queryable, tableName) =>
  queryable->tableOn(Surrealdb_Table.make(tableName))

let ofIdOn = (queryable, queryId) =>
  queryable->ofOn(queryId)

let awaitManaged = livePromise =>
  livePromise->thenManaged(subscription => subscription)

let awaitUnmanaged = livePromise =>
  livePromise->thenUnmanaged(subscription => subscription)

let table = (db, tableValue) =>
  db->Surrealdb_Surreal.asQueryable->tableOn(tableValue)

let of_ = (db, queryId) =>
  db->Surrealdb_Surreal.asQueryable->ofOn(queryId)
