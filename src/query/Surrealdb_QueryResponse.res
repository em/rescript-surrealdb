// src/bindings/Surrealdb_QueryResponse.res — SurrealDB QueryResponse binding.
// Concern: model the structured success/failure response objects returned by
// Query.responses() in the public SDK.
type t

@get external success: t => bool = "success"
@get external statsRaw: t => Nullable.t<Surrealdb_QueryStats.t> = "stats"
@get external resultRaw: t => Nullable.t<unknown> = "result"
@get external errorRaw: t => Nullable.t<Surrealdb_ServerError.t> = "error"
@get external typeRaw: t => Nullable.t<string> = "type"

let stats = response =>
  response->statsRaw->Nullable.toOption

let result = response =>
  response->resultRaw->Nullable.toOption->Option.map(Surrealdb_Value.fromUnknown)

let error = response =>
  response->errorRaw->Nullable.toOption

let type_ = response =>
  response->typeRaw->Nullable.toOption->Option.map(raw =>
    switch raw->Surrealdb_QueryType.parse {
    | Some(value) => value
    | None => throw(Failure(`Unexpected SurrealDB query type: ${raw}`))
    }
  )
