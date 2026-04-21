type t<'value>

let recordNoDataOn: (
  Surrealdb_Queryable.t,
  Surrealdb_RecordId.t,
  Surrealdb_Table.t,
  Surrealdb_RecordId.t,
) => t<Surrealdb_JsValue.t>
let recordWithDataOn: (
  Surrealdb_Queryable.t,
  Surrealdb_RecordId.t,
  Surrealdb_Table.t,
  Surrealdb_RecordId.t,
  dict<Surrealdb_JsValue.t>,
) => t<Surrealdb_JsValue.t>
let recordArraysNoDataOn: (
  Surrealdb_Queryable.t,
  array<Surrealdb_RecordId.t>,
  Surrealdb_Table.t,
  array<Surrealdb_RecordId.t>,
) => t<Surrealdb_JsValue.t>
let recordArraysWithDataOn: (
  Surrealdb_Queryable.t,
  array<Surrealdb_RecordId.t>,
  Surrealdb_Table.t,
  array<Surrealdb_RecordId.t>,
  dict<Surrealdb_JsValue.t>,
) => t<Surrealdb_JsValue.t>
let recordsOn: (
  Surrealdb_Queryable.t,
  Surrealdb_RecordId.t,
  Surrealdb_Table.t,
  Surrealdb_RecordId.t,
  ~data: dict<Surrealdb_JsValue.t>=?,
  unit,
) => t<Surrealdb_JsValue.t>
let recordArraysOn: (
  Surrealdb_Queryable.t,
  array<Surrealdb_RecordId.t>,
  Surrealdb_Table.t,
  array<Surrealdb_RecordId.t>,
  ~data: dict<Surrealdb_JsValue.t>=?,
  unit,
) => t<Surrealdb_JsValue.t>
let records: (
  Surrealdb_Surreal.t,
  Surrealdb_RecordId.t,
  Surrealdb_Table.t,
  Surrealdb_RecordId.t,
  ~data: dict<Surrealdb_JsValue.t>=?,
  unit,
) => t<Surrealdb_JsValue.t>
let recordArrays: (
  Surrealdb_Surreal.t,
  array<Surrealdb_RecordId.t>,
  Surrealdb_Table.t,
  array<Surrealdb_RecordId.t>,
  ~data: dict<Surrealdb_JsValue.t>=?,
  unit,
) => t<Surrealdb_JsValue.t>
let unique: t<'value> => t<'value>
let outputRaw: (t<'value>, string) => t<'value>
let timeout: (t<'value>, Surrealdb_Duration.t) => t<'value>
let version: (t<'value>, Surrealdb_DateTime.t) => t<'value>
let json: t<'value> => t<'value>
let compile: t<'value> => Surrealdb_BoundQuery.t
let stream: t<'value> => Surrealdb_AsyncIterable.t<Surrealdb_Frame.t<'value>>
let thenResolve: (t<'value>, ('value => 'value)) => promise<'value>
let output: (t<'value>, Surrealdb_Output.t) => t<'value>
let resolve: t<'value> => promise<'value>
