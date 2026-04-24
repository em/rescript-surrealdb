// src/bindings/Surrealdb_ApiResponse.res — SurrealDB API response binding.
// Concern: bind the ApiResponse object shape used by API failures and compiled API
// queries. Source: surrealdb.d.ts — ApiResponse<T> has optional body, headers, and
// status fields.
type t

@get external bodyRaw: t => Nullable.t<unknown> = "body"
@get external headersRaw: t => Nullable.t<dict<string>> = "headers"
@get external statusRaw: t => Nullable.t<int> = "status"

let body = response =>
  response->bodyRaw->Nullable.toOption->Option.map(Surrealdb_Value.fromUnknown)

let headers = response =>
  response->headersRaw->Nullable.toOption

let status = response =>
  response->statusRaw->Nullable.toOption

let headersToJsonObject = values =>
  values
  ->Dict.toArray
  ->Array.map(((key, value)) => (key, JSON.Encode.string(value)))
  ->Dict.fromArray

let toJsonObject = response =>
  [
    switch response->status {
    | Some(value) => [("status", JSON.Encode.int(value))]
    | None => []
    },
    switch response->headers {
    | Some(values) => [("headers", JSON.Encode.object(values->headersToJsonObject))]
    | None => []
    },
    switch response->body {
    | Some(value) => [("body", value->Surrealdb_Value.toJSON)]
    | None => []
    },
  ]
  ->Belt.Array.concatMany
  ->Dict.fromArray

let toJSON = response =>
  response->toJsonObject->JSON.Encode.object
