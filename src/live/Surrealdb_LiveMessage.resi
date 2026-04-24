type t

let queryId: t => Surrealdb_Uuid.t
let action: t => Surrealdb_LiveActions.t
let recordId: t => Surrealdb_RecordId.t
let value: t => Surrealdb_Value.t
