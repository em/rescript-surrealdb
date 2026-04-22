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

let toJsonObject = response => {
  let payload = Dict.make()
  switch response->status {
  | Some(value) => payload->Dict.set("status", JSON.Encode.int(value))
  | None => ()
  }
  switch response->headers {
  | Some(values) =>
    let headersJson = Dict.make()
    values->Dict.toArray->Array.forEach(((key, value)) =>
      headersJson->Dict.set(key, JSON.Encode.string(value))
    )
    payload->Dict.set("headers", JSON.Encode.object(headersJson))
  | None => ()
  }
  switch response->body {
  | Some(value) =>
    payload->Dict.set("body", value->Surrealdb_Value.toJSON)
  | None => ()
  }
  payload
}

let toJSON = response =>
  response->toJsonObject->JSON.Encode.object
