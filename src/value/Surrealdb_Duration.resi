type t
type ctor
type compact = array<BigInt.t>

let fromString: string => t
let fromBigInt: BigInt.t => t
let fromCompact: compact => t
let ctor: ctor
let toString: t => string
let equals: (t, unknown) => bool
let toJSON: t => string
let toCompact: t => compact
let add: (t, t) => t
let sub: (t, t) => t
let mulByInt: (t, int) => t
let mulByBigInt: (t, BigInt.t) => t
let divByDuration: (t, t) => BigInt.t
let divByInt: (t, int) => t
let divByBigInt: (t, BigInt.t) => t
let mod: (t, t) => t
let nanoseconds: t => BigInt.t
let microseconds: t => BigInt.t
let milliseconds: t => BigInt.t
let seconds: t => BigInt.t
let minutes: t => BigInt.t
let hours: t => BigInt.t
let days: t => BigInt.t
let weeks: t => BigInt.t
let years: t => BigInt.t
let parseString: string => compact
let parseFloat: string => t
let nanosecondsValue: int => t
let microsecondsValue: int => t
let millisecondsValue: int => t
let secondsValue: int => t
let minutesValue: int => t
let hoursValue: int => t
let daysValue: int => t
let weeksValue: int => t
let yearsValue: int => t
let measure: unit => unit => t
let isInstance: unknown => bool
let fromUnknown: unknown => option<t>
