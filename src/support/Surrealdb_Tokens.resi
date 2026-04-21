type t

let make: (~access: string, ~refresh: string=?, unit) => t
let access: t => string
let refreshRaw: t => Nullable.t<string>
let refresh: t => option<string>
let toJSON: t => JSON.t
