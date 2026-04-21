type t
type ctor

let ctor: ctor
let name: t => string
let message: t => string
let stackRaw: t => Nullable.t<string>
let causeRaw: t => Nullable.t<unknown>
let stack: t => option<string>
let cause: t => option<unknown>
let isInstance: unknown => bool
let fromUnknown: unknown => option<t>
let toJsonObject: t => dict<JSON.t>
let toJSON: t => JSON.t
