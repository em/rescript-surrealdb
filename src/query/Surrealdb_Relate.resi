type t<'value>

let recordNoDataOn: (
  Surrealdb_Queryable.t,
  Surrealdb_RecordId.t,
  Surrealdb_Table.t,
  Surrealdb_RecordId.t,
) => t<Surrealdb_Value.t>
let recordWithDataOn: (
  Surrealdb_Queryable.t,
  Surrealdb_RecordId.t,
  Surrealdb_Table.t,
  Surrealdb_RecordId.t,
  dict<Surrealdb_JsValue.t>,
) => t<Surrealdb_Value.t>
let recordArraysNoDataOn: (
  Surrealdb_Queryable.t,
  array<Surrealdb_RecordId.t>,
  Surrealdb_Table.t,
  array<Surrealdb_RecordId.t>,
) => t<Surrealdb_Value.t>
let recordArraysWithDataOn: (
  Surrealdb_Queryable.t,
  array<Surrealdb_RecordId.t>,
  Surrealdb_Table.t,
  array<Surrealdb_RecordId.t>,
  dict<Surrealdb_JsValue.t>,
) => t<Surrealdb_Value.t>
let recordsOn: (
  Surrealdb_Queryable.t,
  Surrealdb_RecordId.t,
  Surrealdb_Table.t,
  Surrealdb_RecordId.t,
  ~data: dict<Surrealdb_JsValue.t>=?,
  unit,
) => t<Surrealdb_Value.t>
let recordArraysOn: (
  Surrealdb_Queryable.t,
  array<Surrealdb_RecordId.t>,
  Surrealdb_Table.t,
  array<Surrealdb_RecordId.t>,
  ~data: dict<Surrealdb_JsValue.t>=?,
  unit,
) => t<Surrealdb_Value.t>
let records: (
  Surrealdb_Surreal.t,
  Surrealdb_RecordId.t,
  Surrealdb_Table.t,
  Surrealdb_RecordId.t,
  ~data: dict<Surrealdb_JsValue.t>=?,
  unit,
) => t<Surrealdb_Value.t>
let recordArrays: (
  Surrealdb_Surreal.t,
  array<Surrealdb_RecordId.t>,
  Surrealdb_Table.t,
  array<Surrealdb_RecordId.t>,
  ~data: dict<Surrealdb_JsValue.t>=?,
  unit,
) => t<Surrealdb_Value.t>
let unique: t<'value> => t<'value>
let outputRaw: (t<'value>, string) => t<'value>
let timeout: (t<'value>, Surrealdb_Duration.t) => t<'value>
let version: (t<'value>, Surrealdb_DateTime.t) => t<'value>
let json: t<'value> => t<JSON.t>
let compile: t<'value> => Surrealdb_BoundQuery.t
let stream: t<Surrealdb_Value.t> => Surrealdb_AsyncIterable.t<Surrealdb_QueryFrame.t>
let streamJson: t<JSON.t> => Surrealdb_AsyncIterable.t<Surrealdb_JsonFrame.t>
let thenResolve: (
  t<Surrealdb_Value.t>,
  (Surrealdb_Value.t => Surrealdb_Value.t),
) => promise<Surrealdb_Value.t>
let thenResolveJson: (t<JSON.t>, (JSON.t => JSON.t)) => promise<JSON.t>
let output: (t<'value>, Surrealdb_Output.t) => t<'value>
let resolve: t<Surrealdb_Value.t> => promise<Surrealdb_Value.t>
let resolveJson: t<JSON.t> => promise<JSON.t>
