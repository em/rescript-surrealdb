type t<'value>

let functionNoArgsOn: (Surrealdb_Queryable.t, string) => t<Surrealdb_JsValue.t>
let functionOn: (Surrealdb_Queryable.t, string, array<Surrealdb_JsValue.t>) => t<Surrealdb_JsValue.t>
let versionedFunctionNoArgsOn: (Surrealdb_Queryable.t, string, string) => t<Surrealdb_JsValue.t>
let versionedFunctionOn: (
  Surrealdb_Queryable.t,
  string,
  string,
  array<Surrealdb_JsValue.t>,
) => t<Surrealdb_JsValue.t>
let callOn: (
  Surrealdb_Queryable.t,
  string,
  ~args: array<Surrealdb_JsValue.t>=?,
  unit,
) => t<Surrealdb_JsValue.t>
let callVersionedOn: (
  Surrealdb_Queryable.t,
  string,
  string,
  ~args: array<Surrealdb_JsValue.t>=?,
  unit,
) => t<Surrealdb_JsValue.t>
let function_: (
  Surrealdb_Surreal.t,
  string,
  ~args: array<Surrealdb_JsValue.t>=?,
  unit,
) => t<Surrealdb_JsValue.t>
let versionedFunction: (
  Surrealdb_Surreal.t,
  string,
  string,
  ~args: array<Surrealdb_JsValue.t>=?,
  unit,
) => t<Surrealdb_JsValue.t>
let json: t<'value> => t<'value>
let compile: t<'value> => Surrealdb_BoundQuery.t
let stream: t<'value> => Surrealdb_AsyncIterable.t<Surrealdb_Frame.t<'value>>
let thenResolve: (t<'value>, ('value => 'value)) => promise<'value>
let resolve: t<'value> => promise<'value>
