type t =
  | Base(Surrealdb_SurrealError.t)
  | Client(Surrealdb_SurrealError.t)
  | Server(Surrealdb_ServerError.t)

let fromSurrealError: Surrealdb_SurrealError.t => t
let fromUnknown: unknown => option<t>
let toJsonObject: t => dict<JSON.t>
let toJSON: t => JSON.t
