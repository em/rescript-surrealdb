type t
type ctor

let fromString: string => t
let fromRecordId: Surrealdb_RecordId.t => t
let fromStringRecordId: t => t
let ctor: ctor
let toString: t => string
let equals: (t, unknown) => bool
let toJSON: t => string
let isInstance: unknown => bool
let fromUnknown: unknown => option<t>
