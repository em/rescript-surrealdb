type t<'value>

let json: t<'value> => t<'value>
let header: (t<'value>, string, string) => t<'value>
let query: (t<'value>, string, string) => t<'value>
let value: t<'value> => t<Surrealdb_Value.t>
let compile: t<'value> => Surrealdb_BoundQuery.t
let stream: t<'value> => Surrealdb_AsyncIterable.t<Surrealdb_Frame.t<Surrealdb_ApiResponse.t>>
let then_: (t<'value>, ('value => 'value)) => promise<'value>
let resolve: t<'value> => promise<'value>
let awaitValue: t<'value> => promise<'value>
