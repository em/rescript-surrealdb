type t
type ctor

let makeRaw: array<Surrealdb_GeometryLine.t> => t
let ctor: ctor
let asGeometry: t => Surrealdb_Geometry.t
let lines: t => array<Surrealdb_GeometryLine.t>
let coordinates: t => array<array<array<float>>>
let toString: t => string
let equals: (t, unknown) => bool
let clone: t => t
let matches: (t, Surrealdb_Geometry.t) => bool
let toJSONRaw: t => unknown
let make: (~first: Surrealdb_GeometryLine.t, ~rest: array<Surrealdb_GeometryLine.t>=?) => t
let toJSON: t => JSON.t
let isInstance: unknown => bool
let fromUnknown: unknown => option<t>
