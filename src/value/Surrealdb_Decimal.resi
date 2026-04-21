type t
type ctor

let fromString: string => t
let fromFloat: float => t
let fromBigInt: BigInt.t => t
let ctor: ctor
let toString: t => string
let equals: (t, unknown) => bool
let toJSON: t => string
let add: (t, t) => t
let sub: (t, t) => t
let mul: (t, t) => t
let div: (t, t) => t
let mod: (t, t) => t
let abs: t => t
let neg: t => t
let isZero: t => bool
let isNegative: t => bool
let compare: (t, t) => int
let round: (t, int) => t
let toFixed: (t, int) => string
let toFloat: t => float
let toBigInt: t => BigInt.t
let toScientific: t => string
let intPart: t => BigInt.t
let fracPart: t => BigInt.t
let scale: t => int
let fromScientificNotation: string => t
let isInstance: unknown => bool
let fromUnknown: unknown => option<t>
