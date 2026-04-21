// src/bindings/Surrealdb_Select.res — SurrealDB SelectPromise binding.
// Concern: bind the SelectPromise class from the surrealdb SDK.
// Source: node_modules/surrealdb/dist/surrealdb.d.ts — SurrealQueryable.select()
// returns SelectPromise with fields(), value(), start(), limit(), where(),
// fetch(), json(), and compile() for BoundQuery generation.
type t<'value>

@send
external fromTableOn: (Surrealdb_Queryable.t, Surrealdb_Table.t) => t<Surrealdb_JsValue.t> = "select"

@send
external fromRecordIdOn: (Surrealdb_Queryable.t, Surrealdb_RecordId.t) => t<Surrealdb_JsValue.t> = "select"

@send
external fromRangeOn: (Surrealdb_Queryable.t, Surrealdb_RecordIdRange.t) => t<Surrealdb_JsValue.t> = "select"

let tableOn = (queryable, tableName) => queryable->fromTableOn(Surrealdb_Table.make(tableName))
let recordOn = (queryable, tableName, recordSlug) =>
  queryable->fromRecordIdOn(Surrealdb_RecordId.make(tableName, recordSlug))
let rangeOn = (queryable, range) =>
  queryable->fromRangeOn(range)

let table = (db, tableName) => tableOn(db->Surrealdb_Surreal.asQueryable, tableName)
let record = (db, tableName, recordSlug) =>
  recordOn(db->Surrealdb_Surreal.asQueryable, tableName, recordSlug)
let range = (db, rangeValue) =>
  rangeOn(db->Surrealdb_Surreal.asQueryable, rangeValue)

@send @variadic
external fields: (t<'value>, array<string>) => t<'value> = "fields"

@send
external value: (t<'value>, string) => t<'value> = "value"

@send
external start: (t<'value>, int) => t<'value> = "start"

@send
external limit: (t<'value>, int) => t<'value> = "limit"

@send
external where: (t<'value>, Surrealdb_Expr.t) => t<'value> = "where"

@send @variadic
external fetch: (t<'value>, array<string>) => t<'value> = "fetch"

@send
external timeout: (t<'value>, Surrealdb_Duration.t) => t<'value> = "timeout"

@send
external version: (t<'value>, Surrealdb_DateTime.t) => t<'value> = "version"

@send
external json: t<'value> => t<'value> = "json"

@send
external compile: t<'value> => Surrealdb_BoundQuery.t = "compile"

@send
external stream: t<'value> => Surrealdb_AsyncIterable.t<Surrealdb_Frame.t<'value>> = "stream"

@send
external thenResolve: (t<'value>, @uncurry ('value => 'value)) => promise<'value> = "then"

let resolve = promise =>
  promise->thenResolve(value => value)
