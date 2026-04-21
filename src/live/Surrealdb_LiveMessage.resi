type t

let queryId: t => Surrealdb_Uuid.t
let action: t => string
let recordId: t => Surrealdb_RecordId.t
let value: t => unknown
