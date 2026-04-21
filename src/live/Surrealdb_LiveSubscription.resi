type t

let id: t => Surrealdb_Uuid.t
let isManaged: t => bool
let resource: t => option<Surrealdb_Table.t>
let isAlive: t => bool
let kill: t => promise<unit>
let subscribe: (t, Surrealdb_LiveMessage.t => unit) => unit => unit
