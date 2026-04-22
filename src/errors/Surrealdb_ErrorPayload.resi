type rec t =
  | Undefined
  | Null
  | String(string)
  | Boolean(bool)
  | Number(float)
  | BigInt(BigInt.t)
  | Function
  | Symbol
  | SurrealValue(Surrealdb_Value.t)
  | Array(array<t>)
  | Object(dict<t>)
  | OpaqueObject

let fromUnknown: unknown => t
let classifyDict: dict<unknown> => dict<t>
let toJSON: t => JSON.t
