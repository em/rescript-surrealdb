type t
type ctor

let makeRaw: array<Surrealdb_GeometryPoint.t> => t
let ctor: ctor
let asGeometry: t => Surrealdb_Geometry.t
let points: t => array<Surrealdb_GeometryPoint.t>
let coordinates: t => array<array<float>>
let toString: t => string
let equals: (t, unknown) => bool
let clone: t => t
let matches: (t, Surrealdb_Geometry.t) => bool
let toJSONRaw: t => unknown
let make: (~first: Surrealdb_GeometryPoint.t, ~rest: array<Surrealdb_GeometryPoint.t>=?) => t
let toJSON: t => JSON.t
let isInstance: unknown => bool
let fromUnknown: unknown => option<t>
