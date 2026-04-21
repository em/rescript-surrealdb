// src/bindings/Surrealdb_Create.res — SurrealDB CreatePromise binding.
// Concern: bind the CreatePromise class from the surrealdb SDK.
// Source: node_modules/surrealdb/dist/surrealdb.d.ts — SurrealQueryable.create()
// returns CreatePromise with content(), patch(), json(), and compile().
type t<'value>

@send
external fromRecordIdOn: (Surrealdb_Queryable.t, Surrealdb_RecordId.t) => t<Surrealdb_JsValue.t> = "create"

@send
external fromTableOn: (Surrealdb_Queryable.t, Surrealdb_Table.t) => t<Surrealdb_JsValue.t> = "create"

let recordOn = (queryable, tableName, recordSlug) =>
  queryable->fromRecordIdOn(Surrealdb_RecordId.make(tableName, recordSlug))

let tableOn = (queryable, tableName) =>
  queryable->fromTableOn(Surrealdb_Table.make(tableName))

let fromRecordId = (db, recordId) =>
  db->Surrealdb_Surreal.asQueryable->fromRecordIdOn(recordId)

let fromTable = (db, table) =>
  db->Surrealdb_Surreal.asQueryable->fromTableOn(table)

@send
external content: (t<'value>, dict<Surrealdb_JsValue.t>) => t<'value> = "content"

@send
external patch: (t<'value>, Surrealdb_JsValue.t) => t<'value> = "patch"

@send
external outputRaw: (t<'value>, string) => t<'value> = "output"

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

let output = (promise, mode) =>
  promise->outputRaw(mode->Surrealdb_Output.toString)

let resolve = promise =>
  promise->thenResolve(value => value)
