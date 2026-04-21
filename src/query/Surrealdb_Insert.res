// src/bindings/Surrealdb_Insert.res — SurrealDB InsertPromise binding.
// Concern: bind the InsertPromise class from the surrealdb SDK.
// Source: node_modules/surrealdb/dist/surrealdb.d.ts — SurrealQueryable.insert()
// returns InsertPromise with relation(), ignore(), json(), and compile().
type t<'value>

@send
external fromDataOn: (Surrealdb_Queryable.t, Surrealdb_JsValue.t) => t<Surrealdb_JsValue.t> = "insert"

@send
external intoTableOn: (
  Surrealdb_Queryable.t,
  Surrealdb_Table.t,
  Surrealdb_JsValue.t,
) => t<Surrealdb_JsValue.t> = "insert"

let dataOn = (queryable, data) =>
  queryable->fromDataOn(data)

let tableOn = (queryable, tableName, data) =>
  queryable->intoTableOn(Surrealdb_Table.make(tableName), data)

let fromData = (db, data) =>
  db->Surrealdb_Surreal.asQueryable->fromDataOn(data)

let intoTable = (db, table, data) =>
  db->Surrealdb_Surreal.asQueryable->intoTableOn(table, data)

@send
external relation: t<'value> => t<'value> = "relation"

@send
external ignore: t<'value> => t<'value> = "ignore"

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
