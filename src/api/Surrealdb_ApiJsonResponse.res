// src/bindings/Surrealdb_ApiJsonResponse.res — JSON-mode API response binding.
// Concern: preserve the API response envelope after `.json()` without collapsing
// it into a bare `JSON.t`.
// Source: surrealdb.d.ts — `ApiResponse<T>` keeps `body`, `headers`, and `status`
// while `.json()` only JSONifies the payload.
// Boundary: body stays JSON-mode, while headers and status preserve their exact
// envelope fields.
// Why this shape: API `.json()` changes body format, not whether the response is
// still an API response envelope.
// Coverage: tests/connection/SurrealdbSessionSurface_test.res.
type t

@get external bodyRaw: t => Nullable.t<unknown> = "body"
@get external headersRaw: t => Nullable.t<dict<string>> = "headers"
@get external statusRaw: t => Nullable.t<int> = "status"
external jsonFromUnknown: unknown => JSON.t = "%identity"

let body = response =>
  response->bodyRaw->Nullable.toOption->Option.map(jsonFromUnknown)

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
    | Some(value) => [("body", value)]
    | None => []
    },
  ]
  ->Belt.Array.concatMany
  ->Dict.fromArray

let toJSON = response =>
  response->toJsonObject->JSON.Encode.object
