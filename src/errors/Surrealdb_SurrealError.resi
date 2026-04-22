type t
type ctor
type cause =
  | Error(t)
  | ForeignPayload(Surrealdb_ErrorPayload.t)

let ctor: ctor
let name: t => string
let message: t => string
let stackRaw: t => Nullable.t<string>
let stack: t => option<string>
let cause: t => option<cause>
let isInstance: unknown => bool
let fromUnknown: unknown => option<t>
let toJsonObject: t => dict<JSON.t>
let toJSON: t => JSON.t
