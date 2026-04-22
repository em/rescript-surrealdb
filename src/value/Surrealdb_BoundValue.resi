type rec t =
  | Undefined
  | Null
  | Bool(bool)
  | Int(int)
  | Float(float)
  | String(string)
  | BigInt(BigInt.t)
  | Function
  | Symbol
  | ValueClass(Surrealdb_ValueClass.t)
  | Array(array<t>)
  | Object(dict<t>)

let fromUnknown: unknown => t
let toText: t => string
let toJSON: t => JSON.t
