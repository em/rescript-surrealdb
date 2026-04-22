type t
type ctor

let ctor: ctor
let asGeometry: t => Surrealdb_Geometry.t
let collection: t => array<Surrealdb_Geometry.t>
let geometries: t => array<JSON.t>
let toString: t => string
let equals: (t, unknown) => bool
let clone: t => t
let matches: (t, Surrealdb_Geometry.t) => bool
let make: (~first: Surrealdb_Geometry.t, ~rest: array<Surrealdb_Geometry.t>=?) => t
let toJSON: t => JSON.t
let isInstance: unknown => bool
let fromUnknown: unknown => option<t>
