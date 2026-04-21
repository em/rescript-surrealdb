type t
type ctor

let make: string => t
let ctor: ctor
let body: t => string
let toJSON: t => string
let toString: t => string
let equals: (t, unknown) => bool
let isInstance: unknown => bool
let fromUnknown: unknown => option<t>
