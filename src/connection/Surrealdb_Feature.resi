type t

let name: t => string
let sinceVersionRaw: t => Nullable.t<string>
let untilVersionRaw: t => Nullable.t<string>
let supports: (t, string) => bool
let sinceVersion: t => option<string>
let untilVersion: t => option<string>
let toJsonObject: t => dict<JSON.t>
let toJSON: t => JSON.t
let isInstance: unknown => bool
let fromUnknown: unknown => option<t>
