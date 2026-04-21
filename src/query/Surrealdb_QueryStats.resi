type t

let recordsReceived: t => int
let bytesReceived: t => int
let recordsScanned: t => int
let bytesScanned: t => int
let duration: t => Surrealdb_Duration.t
let toJsonObject: t => dict<JSON.t>
let toJSON: t => JSON.t
