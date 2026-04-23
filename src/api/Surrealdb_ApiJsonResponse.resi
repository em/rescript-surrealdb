type t

let headersRaw: t => Nullable.t<dict<string>>
let statusRaw: t => Nullable.t<int>
let body: t => option<JSON.t>
let headers: t => option<dict<string>>
let status: t => option<int>
let toJsonObject: t => dict<JSON.t>
let toJSON: t => JSON.t
