type t<'value>

let fromDataOn: (Surrealdb_Queryable.t, Surrealdb_JsValue.t) => t<Surrealdb_JsValue.t>
let intoTableOn: (Surrealdb_Queryable.t, Surrealdb_Table.t, Surrealdb_JsValue.t) => t<Surrealdb_JsValue.t>
let dataOn: (Surrealdb_Queryable.t, Surrealdb_JsValue.t) => t<Surrealdb_JsValue.t>
let tableOn: (Surrealdb_Queryable.t, string, Surrealdb_JsValue.t) => t<Surrealdb_JsValue.t>
let fromData: (Surrealdb_Surreal.t, Surrealdb_JsValue.t) => t<Surrealdb_JsValue.t>
let intoTable: (Surrealdb_Surreal.t, Surrealdb_Table.t, Surrealdb_JsValue.t) => t<Surrealdb_JsValue.t>
let relation: t<'value> => t<'value>
let ignore: t<'value> => t<'value>
let outputRaw: (t<'value>, string) => t<'value>
let timeout: (t<'value>, Surrealdb_Duration.t) => t<'value>
let version: (t<'value>, Surrealdb_DateTime.t) => t<'value>
let json: t<'value> => t<'value>
let compile: t<'value> => Surrealdb_BoundQuery.t
let stream: t<'value> => Surrealdb_AsyncIterable.t<Surrealdb_Frame.t<'value>>
let thenResolve: (t<'value>, ('value => 'value)) => promise<'value>
let output: (t<'value>, Surrealdb_Output.t) => t<'value>
let resolve: t<'value> => promise<'value>
