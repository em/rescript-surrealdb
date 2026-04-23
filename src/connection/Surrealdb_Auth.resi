type t<'value>

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
