type t<'value>

let fromDataOn: (Surrealdb_Queryable.t, Surrealdb_JsValue.t) => t<Surrealdb_Value.t>
let intoTableOn: (Surrealdb_Queryable.t, Surrealdb_Table.t, Surrealdb_JsValue.t) => t<Surrealdb_Value.t>
let dataOn: (Surrealdb_Queryable.t, Surrealdb_JsValue.t) => t<Surrealdb_Value.t>
let tableOn: (Surrealdb_Queryable.t, string, Surrealdb_JsValue.t) => t<Surrealdb_Value.t>
let fromData: (Surrealdb_Surreal.t, Surrealdb_JsValue.t) => t<Surrealdb_Value.t>
let intoTable: (Surrealdb_Surreal.t, Surrealdb_Table.t, Surrealdb_JsValue.t) => t<Surrealdb_Value.t>
let relation: t<'value> => t<'value>
let ignore: t<'value> => t<'value>
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
