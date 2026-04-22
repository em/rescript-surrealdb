// src/bindings/Surrealdb_SurrealError.res — SurrealDB base error binding.
// Concern: bind the SDK-wide SurrealError base class and preserve recursive causes.
// Source: surrealdb.d.ts — SurrealError extends Error and underpins both server and
// client-side SDK failures.
type t
type ctor
type cause =
  | Error(t)
  | ForeignPayload(Surrealdb_ErrorPayload.t)

@module("surrealdb") external ctor: ctor = "SurrealError"
external unsafeFromUnknown: unknown => t = "%identity"

@get external name: t => string = "name"
@get external message: t => string = "message"
@get external stackRaw: t => Nullable.t<string> = "stack"
@get external causeRaw: t => Nullable.t<unknown> = "cause"

let stack = error =>
  error->stackRaw->Nullable.toOption

let isInstance = value =>
  JsTypeReflection.instanceOfClass(~instance=value, ~class_=ctor)

let rec fromUnknown = value =>
  if isInstance(value) {
    Some(unsafeFromUnknown(value))
  } else {
    None
  }

and classifyCause = rawCause =>
  switch fromUnknown(rawCause) {
  | Some(causeError) => Error(causeError)
  | None => ForeignPayload(rawCause->Surrealdb_ErrorPayload.fromUnknown)
  }

let cause = error =>
  error->causeRaw->Nullable.toOption->Option.map(classifyCause)

let rec toJsonObject = error => {
  let payload = Dict.make()
  payload->Dict.set("name", JSON.Encode.string(error->name))
  payload->Dict.set("message", JSON.Encode.string(error->message))
  switch error->stack {
  | Some(value) => payload->Dict.set("stack", JSON.Encode.string(value))
  | None => ()
  }
  switch error->cause {
  | Some(Error(causeError)) => payload->Dict.set("cause", causeError->toJsonObject->JSON.Encode.object)
  | Some(ForeignPayload(causePayload)) => payload->Dict.set("cause", causePayload->Surrealdb_ErrorPayload.toJSON)
  | None => ()
  }
  payload
}

let toJSON = error =>
  error->toJsonObject->JSON.Encode.object
