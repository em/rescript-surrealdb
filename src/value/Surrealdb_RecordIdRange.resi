type t
type ctor

let makeRaw: (string, option<unknown>, option<unknown>) => t
let ctor: ctor
let table: t => Surrealdb_Table.t
let beginRaw: t => option<unknown>
let endRaw: t => option<unknown>
let toString: t => string
let equals: (t, unknown) => bool
let toJSON: t => string
let make: (
  ~table: string,
  ~begin: Surrealdb_RangeBound.t<'a>=?,
  ~end: Surrealdb_RangeBound.t<'a>=?,
  unit,
) => t
let begin: t => option<Surrealdb_RangeBound.t<'a>>
let end_: t => option<Surrealdb_RangeBound.t<'a>>
let isInstance: unknown => bool
let fromUnknown: unknown => option<t>
