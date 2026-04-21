// src/bindings/Surrealdb_Features.res — SurrealDB exported feature constants.
// Concern: expose the SDK's Features object so isFeatureSupported() has a real
// public feature-value source instead of dead opaque types.
type t

@module("surrealdb") external all: t = "Features"

@get external liveQueries_: t => Surrealdb_Feature.t = "LiveQueries"
@get external sessions_: t => Surrealdb_Feature.t = "Sessions"
@get external api_: t => Surrealdb_Feature.t = "Api"
@get external refreshTokens_: t => Surrealdb_Feature.t = "RefreshTokens"
@get external transactions_: t => Surrealdb_Feature.t = "Transactions"
@get external exportImportRaw_: t => Surrealdb_Feature.t = "ExportImportRaw"
@get external surrealMl_: t => Surrealdb_Feature.t = "SurrealML"

let liveQueries = all->liveQueries_
let sessions = all->sessions_
let api = all->api_
let refreshTokens = all->refreshTokens_
let transactions = all->transactions_
let exportImportRaw = all->exportImportRaw_
let surrealMl = all->surrealMl_

let values = () => [
  liveQueries,
  sessions,
  api,
  refreshTokens,
  transactions,
  exportImportRaw,
  surrealMl,
]

let fromString = raw =>
  switch raw->String.toLowerCase {
  | "live-queries" => Some(liveQueries)
  | "sessions" => Some(sessions)
  | "api" => Some(api)
  | "refresh-tokens" => Some(refreshTokens)
  | "transactions" => Some(transactions)
  | "export-import-raw" => Some(exportImportRaw)
  | "surreal-ml" => Some(surrealMl)
  | _ => None
  }
