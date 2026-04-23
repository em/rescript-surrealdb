type t<'value>

let functionNoArgsOn: (Surrealdb_Queryable.t, string) => t<Surrealdb_Value.t>
let functionOn: (Surrealdb_Queryable.t, string, array<Surrealdb_JsValue.t>) => t<Surrealdb_Value.t>
let versionedFunctionNoArgsOn: (Surrealdb_Queryable.t, string, string) => t<Surrealdb_Value.t>
let versionedFunctionOn: (
  Surrealdb_Queryable.t,
  string,
  string,
  array<Surrealdb_JsValue.t>,
) => t<Surrealdb_Value.t>
let callOn: (
  Surrealdb_Queryable.t,
  string,
  ~args: array<Surrealdb_JsValue.t>=?,
  unit,
) => t<Surrealdb_Value.t>
let callVersionedOn: (
  Surrealdb_Queryable.t,
  string,
  string,
  ~args: array<Surrealdb_JsValue.t>=?,
  unit,
) => t<Surrealdb_Value.t>
let function_: (
  Surrealdb_Surreal.t,
  string,
  ~args: array<Surrealdb_JsValue.t>=?,
  unit,
) => t<Surrealdb_Value.t>
let versionedFunction: (
  Surrealdb_Surreal.t,
  string,
  string,
  ~args: array<Surrealdb_JsValue.t>=?,
  unit,
) => t<Surrealdb_Value.t>
let json: t<'value> => t<JSON.t>
let compile: t<'value> => Surrealdb_BoundQuery.t
let stream: t<Surrealdb_Value.t> => Surrealdb_AsyncIterable.t<Surrealdb_QueryFrame.t>
let streamJson: t<JSON.t> => Surrealdb_AsyncIterable.t<Surrealdb_JsonFrame.t>
let thenResolve: (
  t<Surrealdb_Value.t>,
  (Surrealdb_Value.t => Surrealdb_Value.t),
) => promise<Surrealdb_Value.t>
let thenResolveJson: (t<JSON.t>, (JSON.t => JSON.t)) => promise<JSON.t>
let resolve: t<Surrealdb_Value.t> => promise<Surrealdb_Value.t>
let resolveJson: t<JSON.t> => promise<JSON.t>
