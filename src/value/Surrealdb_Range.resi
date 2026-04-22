type t
type ctor

let ctor: ctor
let toString: t => string
let equals: (t, unknown) => bool
let toJSON: t => string
let make: (~begin: Surrealdb_RangeBound.t=?, ~end: Surrealdb_RangeBound.t=?, unit) => t
let begin: t => option<Surrealdb_RangeBound.t>
let end_: t => option<Surrealdb_RangeBound.t>
let isInstance: unknown => bool
let fromUnknown: unknown => option<t>
