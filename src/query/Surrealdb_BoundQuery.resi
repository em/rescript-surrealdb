type t

let make: unit => t
let fromText: string => t
let fromQuery: (string, dict<Surrealdb_JsValue.t>) => t
let clone: t => t
let mergeBindings: (dict<Surrealdb_JsValue.t>, dict<Surrealdb_JsValue.t>) => unit
let appendQuery: (t, t) => t
let appendText: (t, string) => t
let appendString: (t, string, dict<Surrealdb_JsValue.t>) => t
let appendTemplate: (t, array<string>, array<Surrealdb_JsValue.t>) => t
let query: t => string
let bindings: t => dict<Surrealdb_JsValue.t>
