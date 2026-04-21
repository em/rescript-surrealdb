// src/bindings/Surrealdb_SurrealError.res — SurrealDB base error binding.
// Concern: bind the SDK-wide SurrealError base class and preserve recursive causes.
// Source: surrealdb.d.ts — SurrealError extends Error and underpins both server and
// client-side SDK failures.
type t
type ctor

@module("surrealdb") external ctor: ctor = "SurrealError"
external unsafeFromUnknown: unknown => t = "%identity"

@get external name: t => string = "name"
@get external message: t => string = "message"
@get external stackRaw: t => Nullable.t<string> = "stack"
@get external causeRaw: t => Nullable.t<unknown> = "cause"

let stack = error =>
  error->stackRaw->Nullable.toOption

let cause = error =>
  error->causeRaw->Nullable.toOption

let isInstance = value =>
  JsTypeReflection.instanceOfClass(~instance=value, ~class_=ctor)

let fromUnknown = value =>
  if isInstance(value) {
    Some(unsafeFromUnknown(value))
  } else {
    None
  }

let rec toJsonObject = error => {
  let payload = Dict.make()
  payload->Dict.set("name", JSON.Encode.string(error->name))
  payload->Dict.set("message", JSON.Encode.string(error->message))
  switch error->stack {
  | Some(value) => payload->Dict.set("stack", JSON.Encode.string(value))
  | None => ()
  }
  switch error->cause {
  | Some(rawCause) =>
    let causeJson =
      switch fromUnknown(rawCause) {
      | Some(causeError) => causeError->toJsonObject->JSON.Encode.object
      | None => rawCause->Surrealdb_Value.fromUnknown->Surrealdb_Value.toJSON
      }
    payload->Dict.set("cause", causeJson)
  | None => ()
  }
  payload
}

let toJSON = error =>
  error->toJsonObject->JSON.Encode.object
