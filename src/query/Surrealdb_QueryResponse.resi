type t

let success: t => bool
let statsRaw: t => Nullable.t<Surrealdb_QueryStats.t>
let errorRaw: t => Nullable.t<Surrealdb_ServerError.t>
let typeRaw: t => Nullable.t<string>
let stats: t => option<Surrealdb_QueryStats.t>
let result: t => option<Surrealdb_Value.t>
let error: t => option<Surrealdb_ServerError.t>
let type_: t => option<string>
