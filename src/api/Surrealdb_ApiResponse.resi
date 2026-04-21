type t

let bodyRaw: t => Nullable.t<unknown>
let headersRaw: t => Nullable.t<dict<string>>
let statusRaw: t => Nullable.t<int>
let body: t => option<unknown>
let headers: t => option<dict<string>>
let status: t => option<int>
let toJsonObject: t => dict<JSON.t>
let toJSON: t => JSON.t
