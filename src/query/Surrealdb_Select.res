// src/bindings/Surrealdb_Select.res — SurrealDB SelectPromise binding.
// Concern: bind SelectPromise with explicit classified-value and JSON-result modes.
// Source: surrealdb.d.ts — SelectPromise<T, I, J> resolves to `MaybeJsonify<T, J>`.
// Boundary: configuration methods stay explicit on the builder; `resolve` and
// `stream` expose classified `Surrealdb_Value.t`, while `.json()` moves to
// explicit JSON-mode results.
// Why this shape: select execution does not preserve a caller-chosen payload
// generic, but JSON mode is a real upstream state transition.
// Coverage: tests/connection/SurrealdbSessionSurface_test.res.
type t<'value>

@send
external fromTableOn: (Surrealdb_Queryable.t, Surrealdb_Table.t) => t<Surrealdb_Value.t> = "select"

@send
external fromRecordIdOn: (Surrealdb_Queryable.t, Surrealdb_RecordId.t) => t<Surrealdb_Value.t> = "select"

@send
external fromRangeOn: (Surrealdb_Queryable.t, Surrealdb_RecordIdRange.t) => t<Surrealdb_Value.t> = "select"

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
