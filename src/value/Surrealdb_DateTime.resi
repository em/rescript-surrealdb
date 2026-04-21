type t
type ctor
type compact = (BigInt.t, BigInt.t)

let now: unit => t
let fromDate: Date.t => t
let fromString: string => t
let fromMilliseconds: float => t
let fromBigInt: BigInt.t => t
let fromCompact: compact => t
let ctor: ctor
let toISOString: t => string
let toDate: t => Date.t
let toString: t => string
let equals: (t, unknown) => bool
let toJSON: t => string
let toCompact: t => compact
let nanoseconds: t => BigInt.t
let microseconds: t => BigInt.t
let milliseconds: t => float
let seconds: t => float
let add: (t, Surrealdb_Duration.t) => t
let sub: (t, Surrealdb_Duration.t) => t
let diff: (t, t) => Surrealdb_Duration.t
let compare: (t, t) => int
let parseString: string => compact
let epoch: unit => t
let fromEpochNanoseconds: BigInt.t => t
let fromEpochMicroseconds: BigInt.t => t
let fromEpochMilliseconds: float => t
let fromEpochSeconds: float => t
let nowValue: unit => t
let isInstance: unknown => bool
let fromUnknown: unknown => option<t>
