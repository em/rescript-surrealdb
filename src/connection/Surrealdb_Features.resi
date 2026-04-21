type t

let all: t
let liveQueries_: t => Surrealdb_Feature.t
let sessions_: t => Surrealdb_Feature.t
let api_: t => Surrealdb_Feature.t
let refreshTokens_: t => Surrealdb_Feature.t
let transactions_: t => Surrealdb_Feature.t
let exportImportRaw_: t => Surrealdb_Feature.t
let surrealMl_: t => Surrealdb_Feature.t
let liveQueries: Surrealdb_Feature.t
let sessions: Surrealdb_Feature.t
let api: Surrealdb_Feature.t
let refreshTokens: Surrealdb_Feature.t
let transactions: Surrealdb_Feature.t
let exportImportRaw: Surrealdb_Feature.t
let surrealMl: Surrealdb_Feature.t
let values: unit => array<Surrealdb_Feature.t>
let fromString: string => option<Surrealdb_Feature.t>
