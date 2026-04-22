type t
type ctor

let ctor: ctor
let table: t => Surrealdb_Table.t
let toString: t => string
let equals: (t, unknown) => bool
let toJSON: t => string
let make: (
  ~table: string,
  ~begin: Surrealdb_RangeBound.t=?,
  ~end: Surrealdb_RangeBound.t=?,
  unit,
) => t
let begin: t => option<Surrealdb_RangeBound.t>
let end_: t => option<Surrealdb_RangeBound.t>
let isInstance: unknown => bool
let fromUnknown: unknown => option<t>
