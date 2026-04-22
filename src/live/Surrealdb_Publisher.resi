type t

let make: unit => t
let subscribe: (t, string, array<Surrealdb_Value.t> => unit) => unit => unit
let subscribeFirst: (t, array<string>) => promise<array<Surrealdb_Value.t>>
let publish: (t, string, array<Surrealdb_JsValue.t>) => unit
