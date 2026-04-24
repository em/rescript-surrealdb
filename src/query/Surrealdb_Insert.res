// src/bindings/Surrealdb_Insert.res — SurrealDB InsertPromise binding.
// Concern: bind InsertPromise with explicit classified-value and JSON-result modes.
// Source: surrealdb.d.ts — InsertPromise<T, J> resolves to `MaybeJsonify<T, J>`.
// Boundary: insert data stays in the input binding domain; resolve and stream
// expose classified `Surrealdb_Value.t` or explicit JSON-mode payloads.
// Why this shape: insert execution does not preserve a caller-chosen payload
// generic, but JSON mode is a real upstream state transition.
// Coverage: tests/query/SurrealdbPromiseConfig_test.res.
type t<'value>

@send
external fromDataOn: (Surrealdb_Queryable.t, Surrealdb_JsValue.t) => t<Surrealdb_Value.t> = "insert"

@send
external intoTableOn: (
  Surrealdb_Queryable.t,
  Surrealdb_Table.t,
  Surrealdb_JsValue.t,
) => t<Surrealdb_Value.t> = "insert"

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
external outputByRaw: (t<'value>, string) => t<'value> = "output"

@send
external version: (t<'value>, Surrealdb_DateTime.t) => t<'value> = "version"

@send
external json: t<'value> => t<JSON.t> = "json"

@send
external compile: t<'value> => Surrealdb_BoundQuery.t = "compile"

@send
external streamRaw: t<'value> => Surrealdb_AsyncIterable.t<Surrealdb_Frame.t<unknown>> = "stream"

@send
external thenRaw: (t<'value>, @uncurry (unknown => unknown)) => promise<unknown> = "then"

external asQueryFrameStream: Surrealdb_AsyncIterable.t<Surrealdb_Frame.t<unknown>> => Surrealdb_AsyncIterable.t<Surrealdb_QueryFrame.t> = "%identity"
external asJsonFrameStream: Surrealdb_AsyncIterable.t<Surrealdb_Frame.t<unknown>> => Surrealdb_AsyncIterable.t<Surrealdb_JsonFrame.t> = "%identity"
external jsonFromUnknown: unknown => JSON.t = "%identity"

let output = (promise, mode) =>
  promise->outputByRaw(mode->Surrealdb_Output.toString)

let stream = promise =>
  promise->streamRaw->asQueryFrameStream

let streamJson = promise =>
  promise->streamRaw->asJsonFrameStream

let resolve = promise =>
  promise->thenRaw(value => value)->Promise.thenResolve(Surrealdb_Value.fromUnknown)

let resolveJson = promise =>
  promise->thenRaw(value => value)->Promise.thenResolve(jsonFromUnknown)

let thenResolve = (promise, callback) =>
  promise->resolve->Promise.thenResolve(callback)

let thenResolveJson = (promise, callback) =>
  promise->resolveJson->Promise.thenResolve(callback)
