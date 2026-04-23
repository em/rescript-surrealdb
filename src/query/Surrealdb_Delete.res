// src/bindings/Surrealdb_Delete.res — SurrealDB DeletePromise binding.
// Concern: bind DeletePromise with explicit classified-value and JSON-result modes.
// Source: surrealdb.d.ts — DeletePromise<T, J> resolves to `MaybeJsonify<T, J>`.
// Boundary: resolve and stream expose classified `Surrealdb_Value.t` or explicit
// JSON-mode payloads instead of input binding helpers.
// Why this shape: delete execution does not preserve a caller-chosen payload
// generic, but JSON mode is a real upstream state transition.
// Coverage: tests/connection/SurrealdbSessionSurface_test.res.
type t<'value>

@send
external fromRecordIdOn: (Surrealdb_Queryable.t, Surrealdb_RecordId.t) => t<Surrealdb_Value.t> = "delete"

@send
external fromTableOn: (Surrealdb_Queryable.t, Surrealdb_Table.t) => t<Surrealdb_Value.t> = "delete"

@send
external fromRangeOn: (Surrealdb_Queryable.t, Surrealdb_RecordIdRange.t) => t<Surrealdb_Value.t> = "delete"

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
external outputRaw: (t<'value>, string) => t<'value> = "output"

@send
external timeout: (t<'value>, Surrealdb_Duration.t) => t<'value> = "timeout"

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
  promise->outputRaw(mode->Surrealdb_Output.toString)

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
