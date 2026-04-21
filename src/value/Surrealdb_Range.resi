type t
type ctor

let makeRaw: (option<unknown>, option<unknown>) => t
let ctor: ctor
let beginRaw: t => option<unknown>
let endRaw: t => option<unknown>
let toString: t => string
let equals: (t, unknown) => bool
let toJSON: t => string
let make: (~begin: Surrealdb_RangeBound.t<'a>=?, ~end: Surrealdb_RangeBound.t<'a>=?, unit) => t
let begin: t => option<Surrealdb_RangeBound.t<'a>>
let end_: t => option<Surrealdb_RangeBound.t<'a>>
let isInstance: unknown => bool
let fromUnknown: unknown => option<t>
