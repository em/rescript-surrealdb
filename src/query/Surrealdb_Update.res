// src/bindings/Surrealdb_Update.res — SurrealDB UpdatePromise binding.
// Concern: bind the UpdatePromise class from the surrealdb SDK.
// Source: node_modules/surrealdb/dist/surrealdb.d.ts — SurrealQueryable.update()
// returns UpdatePromise with content(), merge(), replace(), patch(), where(),
// json(), and compile().
type t<'value>

@send
external fromRecordIdOn: (Surrealdb_Queryable.t, Surrealdb_RecordId.t) => t<Surrealdb_JsValue.t> = "update"

@send
external fromTableOn: (Surrealdb_Queryable.t, Surrealdb_Table.t) => t<Surrealdb_JsValue.t> = "update"

@send
external fromRangeOn: (Surrealdb_Queryable.t, Surrealdb_RecordIdRange.t) => t<Surrealdb_JsValue.t> = "update"

let recordOn = (queryable, tableName, recordSlug) =>
  queryable->fromRecordIdOn(Surrealdb_RecordId.make(tableName, recordSlug))

let tableOn = (queryable, tableName) =>
  queryable->fromTableOn(Surrealdb_Table.make(tableName))

let rangeOn = (queryable, range) =>
  queryable->fromRangeOn(range)

let fromRecordId = (db, recordId) =>
  db->Surrealdb_Surreal.asQueryable->fromRecordIdOn(recordId)

let fromTable = (db, table) =>
  db->Surrealdb_Surreal.asQueryable->fromTableOn(table)

let fromRange = (db, range) =>
  db->Surrealdb_Surreal.asQueryable->fromRangeOn(range)

@send
external content: (t<'value>, dict<Surrealdb_JsValue.t>) => t<'value> = "content"

@send
external merge: (t<'value>, dict<Surrealdb_JsValue.t>) => t<'value> = "merge"

@send
external replace: (t<'value>, dict<Surrealdb_JsValue.t>) => t<'value> = "replace"

@send
external patch: (t<'value>, Surrealdb_JsValue.t) => t<'value> = "patch"

@send
external where: (t<'value>, Surrealdb_Expr.t) => t<'value> = "where"

@send
external outputRaw: (t<'value>, string) => t<'value> = "output"

@send
external timeout: (t<'value>, Surrealdb_Duration.t) => t<'value> = "timeout"

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
