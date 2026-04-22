// src/bindings/Surrealdb_Error.res — package-level error classifier.
// Concern: provide one top-level algebra for base, client, and server SurrealDB
// errors without forcing callers to repeat runtime subclass checks.
type t =
  | Base(Surrealdb_SurrealError.t)
  | Client(Surrealdb_SurrealError.t)
  | Server(Surrealdb_ServerError.t)

external toUnknown: 'a => unknown = "%identity"

let fromSurrealError = error =>
  switch error->toUnknown->Surrealdb_ServerError.fromUnknown {
  | Some(serverError) => Server(serverError)
  | None =>
    if error->toUnknown->Surrealdb_ClientError.isInstance {
      Client(error)
    } else {
      Base(error)
    }
  }

let fromUnknown = value =>
  switch value->Surrealdb_SurrealError.fromUnknown {
  | Some(error) => Some(error->fromSurrealError)
  | None => None
  }

let toJsonObject = error =>
  switch error {
  | Base(value) => value->Surrealdb_SurrealError.toJsonObject
  | Client(value) => value->Surrealdb_ClientError.toJsonObject
  | Server(value) => value->Surrealdb_ServerError.toJsonObject
  }

let toJSON = error =>
  error->toJsonObject->JSON.Encode.object
