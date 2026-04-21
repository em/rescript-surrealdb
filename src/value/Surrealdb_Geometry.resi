type t
type ctor

let ctor: ctor
let toString: t => string
let equals: (t, unknown) => bool
let clone: t => t
let matches: (t, t) => bool
let toJSONRaw: t => unknown
let toJSON: t => JSON.t
let isInstance: unknown => bool
let fromUnknown: unknown => option<t>
