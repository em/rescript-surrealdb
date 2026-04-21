// src/bindings/Surrealdb_QueryStats.res — SurrealDB query statistics binding.
// Concern: bind the QueryStats object returned on frame completion and failures.
// Source: surrealdb.d.ts — QueryStats has received/scanned counters and duration.
type t

@get external recordsReceived: t => int = "recordsReceived"
@get external bytesReceived: t => int = "bytesReceived"
@get external recordsScanned: t => int = "recordsScanned"
@get external bytesScanned: t => int = "bytesScanned"
@get external duration: t => Surrealdb_Duration.t = "duration"

let toJsonObject = stats => {
  let payload = Dict.make()
  payload->Dict.set("recordsReceived", JSON.Encode.int(stats->recordsReceived))
  payload->Dict.set("bytesReceived", JSON.Encode.int(stats->bytesReceived))
  payload->Dict.set("recordsScanned", JSON.Encode.int(stats->recordsScanned))
  payload->Dict.set("bytesScanned", JSON.Encode.int(stats->bytesScanned))
  payload->Dict.set("duration", JSON.Encode.string(stats->duration->Surrealdb_Duration.toString))
  payload
}

let toJSON = stats =>
  stats->toJsonObject->JSON.Encode.object
