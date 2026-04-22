type t
type factory

let create: unit => t
let applyDiagnostics: (t, Surrealdb_Value.t => unit) => t
let ws: t => factory
let wss: t => factory
let http: t => factory
let https: t => factory
let keys: t => array<string>
