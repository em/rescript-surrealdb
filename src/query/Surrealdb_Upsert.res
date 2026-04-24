// src/bindings/Surrealdb_Upsert.res — SurrealDB UpsertPromise binding.
// Concern: bind UpsertPromise with explicit classified-value and JSON-result modes.
// Source: surrealdb.d.ts — UpsertPromise<T, I, J> resolves to `MaybeJsonify<T, J>`.
// Boundary: mutation input stays in SDK input binding types; resolve and stream
// expose classified `Surrealdb_Value.t` or explicit JSON-mode payloads.
// Why this shape: upsert execution does not preserve a caller-chosen payload
// generic, but JSON mode is a real upstream state transition.
// Coverage: tests/connection/SurrealdbSessionSurface_test.res.
type t<'value>

@send
external fromRecordIdOn: (Surrealdb_Queryable.t, Surrealdb_RecordId.t) => t<Surrealdb_Value.t> = "upsert"

@send
external fromTableOn: (Surrealdb_Queryable.t, Surrealdb_Table.t) => t<Surrealdb_Value.t> = "upsert"

@send
external fromRangeOn: (Surrealdb_Queryable.t, Surrealdb_RecordIdRange.t) => t<Surrealdb_Value.t> = "upsert"

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
external outputByRaw: (t<'value>, string) => t<'value> = "output"

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
