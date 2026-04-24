// src/bindings/Surrealdb_QueryStats.res — SurrealDB query statistics binding.
// Concern: bind the QueryStats object returned on frame completion and failures.
// Source: surrealdb.d.ts — QueryStats has received/scanned counters and duration.
type t

@get external recordsReceived: t => int = "recordsReceived"
@get external bytesReceived: t => int = "bytesReceived"
@get external recordsScanned: t => int = "recordsScanned"
@get external bytesScanned: t => int = "bytesScanned"
@get external duration: t => Surrealdb_Duration.t = "duration"

let toJsonObject = stats =>
  [
    [("recordsReceived", JSON.Encode.int(stats->recordsReceived))],
    [("bytesReceived", JSON.Encode.int(stats->bytesReceived))],
    [("recordsScanned", JSON.Encode.int(stats->recordsScanned))],
    [("bytesScanned", JSON.Encode.int(stats->bytesScanned))],
    [("duration", JSON.Encode.string(stats->duration->Surrealdb_Duration.toString))],
  ]
  ->Belt.Array.concatMany
  ->Dict.fromArray

let toJSON = stats =>
  stats->toJsonObject->JSON.Encode.object
