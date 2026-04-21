type t
type factory = unknown => Surrealdb_Engine.t

let asDict: t => dict<factory>
let create: unit => t
let applyDiagnostics: (t, unknown => unit) => t
let ws: t => factory
let wss: t => factory
let http: t => factory
let https: t => factory
let instantiate: (factory, unknown) => Surrealdb_Engine.t
let keys: t => array<string>
