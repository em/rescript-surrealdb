// src/bindings/Surrealdb_Query.res — SurrealDB Query binding.
// Concern: bind the Query class from the surrealdb SDK and centralize the
// BoundQuery-backed statement builders used across the package surface.
// Source: node_modules/surrealdb/dist/surrealdb.d.ts — SurrealQueryable.query()
// accepts raw SurrealQL or BoundQuery and returns Query with collect().
type result = array<Surrealdb_Value.t>

type t<'value>

@send
external textNoBindingsOn: (Surrealdb_Queryable.t, string) => t<result> = "query"

@send
external textWithBindingsOn: (Surrealdb_Queryable.t, string, dict<Surrealdb_JsValue.t>) => t<result> = "query"

@send
external boundOn: (Surrealdb_Queryable.t, Surrealdb_BoundQuery.t) => t<result> = "query"

@get external inner: t<'value> => Surrealdb_BoundQuery.t = "inner"

@send external json: t<'value> => t<'value> = "json"

@send
external collectRaw: t<result> => promise<array<unknown>> = "collect"

@send @variadic
external collectIndexesRaw: (t<result>, array<int>) => promise<array<unknown>> = "collect"

@send
external responses: t<result> => promise<array<Surrealdb_QueryResponse.t>> = "responses"

@send @variadic
external responsesIndexes: (
  t<result>,
  array<int>,
) => promise<array<Surrealdb_QueryResponse.t>> = "responses"

@send
external streamRaw: t<'value> => Surrealdb_AsyncIterable.t<Surrealdb_Frame.t<unknown>> = "stream"

@send
external thenResolve: (t<'value>, @uncurry ('value => 'value)) => promise<'value> = "then"

external asQueryFrameStream: Surrealdb_AsyncIterable.t<Surrealdb_Frame.t<unknown>> => Surrealdb_AsyncIterable.t<Surrealdb_QueryFrame.t> = "%identity"

let classifyResults = values =>
  values->Array.map(Surrealdb_Value.fromUnknown)

let collect = query =>
  query->collectRaw->Promise.thenResolve(classifyResults)

let collectIndexes = (query, indexes) =>
  query->collectIndexesRaw(indexes)->Promise.thenResolve(classifyResults)

let stream = query =>
  query->streamRaw->asQueryFrameStream

let textOn = (queryable, sql, ~bindings=?, ()) =>
  switch bindings {
  | Some(value) => queryable->textWithBindingsOn(sql, value)
  | None => queryable->textNoBindingsOn(sql)
  }

let text = (db, sql, ~bindings=?, ()) =>
  textOn(db->Surrealdb_Surreal.asQueryable, sql, ~bindings?, ())

let runTextOn = (queryable, sql) =>
  queryable->textOn(sql, ())->collect

let runText = (db, sql) =>
  runTextOn(db->Surrealdb_Surreal.asQueryable, sql)

let runBoundOn = (queryable, query) =>
  queryable->boundOn(query)->collect

let runBound = (db, query) =>
  runBoundOn(db->Surrealdb_Surreal.asQueryable, query)

let streamTextOn = (queryable, sql) =>
  queryable->textOn(sql, ())->stream

let streamText = (db, sql) =>
  streamTextOn(db->Surrealdb_Surreal.asQueryable, sql)

let streamBoundOn = (queryable, query) =>
  queryable->boundOn(query)->stream

let streamBound = (db, query) =>
  streamBoundOn(db->Surrealdb_Surreal.asQueryable, query)

let resolve = promise =>
  promise->collect

let statement = (query, bindings) => Surrealdb_BoundQuery.fromQuery(query, bindings)

let runStatementOn = (queryable, query) =>
  runBoundOn(queryable, query)

let runStatement = (db, query) =>
  runStatementOn(db->Surrealdb_Surreal.asQueryable, query)

let streamStatementOn = (queryable, query) =>
  streamBoundOn(queryable, query)

let streamStatement = (db, query) =>
  streamStatementOn(db->Surrealdb_Surreal.asQueryable, query)

let runStatementTextOn = (queryable, sql) =>
  runBoundOn(queryable, statement(sql, Surrealdb_JsValue.emptyBindings))

let runStatementText = (db, sql) =>
  runStatementTextOn(db->Surrealdb_Surreal.asQueryable, sql)

let databaseInfoStatement = () => statement("INFO FOR DB", Surrealdb_JsValue.emptyBindings)

let tableInfoStatement = tableKey => {
  let validatedTableName = Surrealdb_Table.make(tableKey)->Surrealdb_Table.name
  statement(`INFO FOR TABLE ${validatedTableName}`, Surrealdb_JsValue.emptyBindings)
}

let countAllStatement = tableKey => {
  let validatedTableName = Surrealdb_Table.make(tableKey)->Surrealdb_Table.name
  statement(`SELECT count() AS count FROM ${validatedTableName} GROUP ALL;`, Surrealdb_JsValue.emptyBindings)
}

let tableStructureStatement = tableKey => {
  let validatedTableName = Surrealdb_Table.make(tableKey)->Surrealdb_Table.name
  statement(`INFO FOR TABLE ${validatedTableName} STRUCTURE`, Surrealdb_JsValue.emptyBindings)
}

let dbStructureStatement = () => statement("INFO FOR DB STRUCTURE", Surrealdb_JsValue.emptyBindings)
