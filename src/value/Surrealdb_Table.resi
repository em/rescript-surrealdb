type t
type ctor

let make: string => t
let ctor: ctor
let name: t => string
let toString: t => string
let equals: (t, unknown) => bool
let toJSON: t => string
let isInstance: unknown => bool
let fromUnknown: unknown => option<t>
