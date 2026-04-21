// src/bindings/Surrealdb_Live.res — SurrealDB live query binding.
// Concern: bind the managed and unmanaged live-query builders on SurrealQueryable.
// Source: node_modules/surrealdb/dist/surrealdb.d.ts — SurrealQueryable exposes
// live(Table) and liveOf(Uuid), returning ManagedLivePromise and UnmanagedLivePromise.
type managed<'value>
type unmanaged

@send external tableOn: (Surrealdb_Queryable.t, Surrealdb_Table.t) => managed<Surrealdb_JsValue.t> = "live"
@send external ofOn: (Surrealdb_Queryable.t, Surrealdb_Uuid.t) => unmanaged = "liveOf"

@send external diff: managed<'value> => managed<'value> = "diff"
@send @variadic external fields: (managed<'value>, array<string>) => managed<'value> = "fields"
@send external value: (managed<'value>, string) => managed<'value> = "value"
@send external where: (managed<'value>, Surrealdb_Expr.t) => managed<'value> = "where"
@send @variadic external fetch: (managed<'value>, array<string>) => managed<'value> = "fetch"
@send external compile: managed<'value> => Surrealdb_BoundQuery.t = "compile"

@send
external thenManaged: (
  managed<'value>,
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
