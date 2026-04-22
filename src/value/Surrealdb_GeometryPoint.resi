type t
type ctor

type coordinate =
  | Float(float)
  | Decimal(Surrealdb_Decimal.t)

let ctor: ctor
let asGeometry: t => Surrealdb_Geometry.t
let point: t => array<float>
let coordinates: t => array<float>
let toString: t => string
let equals: (t, unknown) => bool
let clone: t => t
let matches: (t, Surrealdb_Geometry.t) => bool
let make: (~longitude: coordinate, ~latitude: coordinate) => t
let toJSON: t => JSON.t
let isInstance: unknown => bool
let fromUnknown: unknown => option<t>
