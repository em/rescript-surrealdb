// src/bindings/Surrealdb_Relate.res — SurrealDB RelatePromise binding.
// Concern: bind RelatePromise with explicit classified-value and JSON-result modes.
// Source: surrealdb.d.ts — RelatePromise<T, J> resolves to `MaybeJsonify<T, J>`.
// Boundary: relation configuration keeps SDK input binding types; resolve and
// stream expose classified `Surrealdb_Value.t` or explicit JSON-mode payloads.
// Why this shape: relate execution does not preserve a caller-chosen payload
// generic, but JSON mode is a real upstream state transition.
// Coverage: tests/connection/SurrealdbSessionSurface_test.res.
type t<'value>

@send
external recordNoDataOn: (
  Surrealdb_Queryable.t,
  Surrealdb_RecordId.t,
  Surrealdb_Table.t,
  Surrealdb_RecordId.t,
 ) => t<Surrealdb_Value.t> = "relate"

@send
external recordWithDataOn: (
  Surrealdb_Queryable.t,
  Surrealdb_RecordId.t,
  Surrealdb_Table.t,
  Surrealdb_RecordId.t,
  dict<Surrealdb_JsValue.t>,
) => t<Surrealdb_Value.t> = "relate"

@send
external recordArraysNoDataOn: (
  Surrealdb_Queryable.t,
  array<Surrealdb_RecordId.t>,
  Surrealdb_Table.t,
  array<Surrealdb_RecordId.t>,
) => t<Surrealdb_Value.t> = "relate"

@send
external recordArraysWithDataOn: (
  Surrealdb_Queryable.t,
  array<Surrealdb_RecordId.t>,
  Surrealdb_Table.t,
  array<Surrealdb_RecordId.t>,
  dict<Surrealdb_JsValue.t>,
) => t<Surrealdb_Value.t> = "relate"

let recordsOn = (queryable, fromRecord, edgeTable, toRecord, ~data=?, ()) =>
  switch data {
  | Some(value) =>
    queryable->recordWithDataOn(fromRecord, edgeTable, toRecord, value)
  | None =>
    queryable->recordNoDataOn(fromRecord, edgeTable, toRecord)
  }

let recordArraysOn = (queryable, fromRecords, edgeTable, toRecords, ~data=?, ()) =>
  switch data {
  | Some(value) =>
    queryable->recordArraysWithDataOn(fromRecords, edgeTable, toRecords, value)
  | None =>
    queryable->recordArraysNoDataOn(fromRecords, edgeTable, toRecords)
  }

let records = (db, fromRecord, edgeTable, toRecord, ~data=?, ()) =>
  db->Surrealdb_Surreal.asQueryable->recordsOn(fromRecord, edgeTable, toRecord, ~data?, ())

let recordArrays = (db, fromRecords, edgeTable, toRecords, ~data=?, ()) =>
  db->Surrealdb_Surreal.asQueryable->recordArraysOn(fromRecords, edgeTable, toRecords, ~data?, ())

@send
external unique: t<'value> => t<'value> = "unique"

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
