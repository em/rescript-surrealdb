type t
type ctor

let ctor: ctor
let toUnknown: t => unknown
let equals: (t, unknown) => bool
let toJSON: t => unknown
let toString: t => string
let isInstance: unknown => bool
let fromUnknown: unknown => option<t>
