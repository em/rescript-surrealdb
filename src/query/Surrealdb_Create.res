// src/bindings/Surrealdb_Create.res — SurrealDB CreatePromise binding.
// Concern: bind CreatePromise with explicit classified-value and JSON-result modes.
// Source: surrealdb.d.ts — CreatePromise<T, I, J> resolves to `MaybeJsonify<T, J>`.
// Boundary: mutation and configuration methods stay explicit on the builder; resolve
// and stream expose classified `Surrealdb_Value.t` or explicit JSON-mode payloads.
// Why this shape: create execution does not preserve a caller-chosen payload
// generic, but JSON mode is a real upstream state transition.
// Coverage: tests/connection/SurrealdbSessionSurface_test.res.
type t<'value>

@send
external fromRecordIdOn: (Surrealdb_Queryable.t, Surrealdb_RecordId.t) => t<Surrealdb_Value.t> = "create"

@send
external fromTableOn: (Surrealdb_Queryable.t, Surrealdb_Table.t) => t<Surrealdb_Value.t> = "create"

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
