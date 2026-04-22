type t
type ctor

let asEngine: t => Surrealdb_Engine.t
let ctor: ctor
let fromEngine: Surrealdb_Engine.t => option<t>
