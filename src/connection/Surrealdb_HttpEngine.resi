type t
type ctor

let asEngine: t => Surrealdb_Engine.t
let unsafeFromEngine: Surrealdb_Engine.t => t
let ctor: ctor
let fromEngine: Surrealdb_Engine.t => option<t>
