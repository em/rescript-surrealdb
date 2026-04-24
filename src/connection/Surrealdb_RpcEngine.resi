type t
type ctor

let asEngine: t => Surrealdb_Engine.t
let ctor: ctor
let version: t => promise<Surrealdb_VersionInfo.t>
let sessions: t => promise<array<Surrealdb_Uuid.t>>
let fromEngine: Surrealdb_Engine.t => option<t>
