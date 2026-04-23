type t
type rec input =
  | Undefined
  | Null
  | Bool(bool)
  | Int(int)
  | Float(float)
  | String(string)
  | BigInt(BigInt.t)
  | ValueClass(Surrealdb_ValueClass.t)
  | Array(array<input>)
  | Object(dict<input>)
type kind =
  | Include
  | Exclude

let included: input => t
let excluded: input => t
let kind: t => kind
let isIncluded: t => bool
let isExcluded: t => bool
let value: t => Surrealdb_BoundValue.t
let isInstance: unknown => bool
let fromUnknown: unknown => option<t>
