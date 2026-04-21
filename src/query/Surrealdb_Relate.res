// src/bindings/Surrealdb_Relate.res — SurrealDB RelatePromise binding.
// Concern: bind the RelatePromise class from the surrealdb SDK.
// Source: node_modules/surrealdb/dist/surrealdb.d.ts — SurrealQueryable.relate()
// returns RelatePromise with compile() and json().
type t<'value>

@send
external recordNoDataOn: (
  Surrealdb_Queryable.t,
  Surrealdb_RecordId.t,
  Surrealdb_Table.t,
  Surrealdb_RecordId.t,
 ) => t<Surrealdb_JsValue.t> = "relate"

@send
external recordWithDataOn: (
  Surrealdb_Queryable.t,
  Surrealdb_RecordId.t,
  Surrealdb_Table.t,
  Surrealdb_RecordId.t,
  dict<Surrealdb_JsValue.t>,
) => t<Surrealdb_JsValue.t> = "relate"

@send
external recordArraysNoDataOn: (
  Surrealdb_Queryable.t,
  array<Surrealdb_RecordId.t>,
  Surrealdb_Table.t,
  array<Surrealdb_RecordId.t>,
) => t<Surrealdb_JsValue.t> = "relate"

@send
external recordArraysWithDataOn: (
  Surrealdb_Queryable.t,
  array<Surrealdb_RecordId.t>,
  Surrealdb_Table.t,
  array<Surrealdb_RecordId.t>,
  dict<Surrealdb_JsValue.t>,
) => t<Surrealdb_JsValue.t> = "relate"

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
