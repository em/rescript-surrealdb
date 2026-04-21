// src/bindings/Surrealdb_Feature.res — SurrealDB feature binding.
// Concern: bind Feature instances surfaced through SDK errors and engine state.
// Source: surrealdb.d.ts — Feature has .name, .sinceVersion, .untilVersion, and
// .supports(version), but is not exported as a top-level constructor.
type t

external unsafeFromUnknown: unknown => t = "%identity"

@get external name: t => string = "name"
@get external sinceVersionRaw: t => Nullable.t<string> = "sinceVersion"
@get external untilVersionRaw: t => Nullable.t<string> = "untilVersion"
@send external supports: (t, string) => bool = "supports"

let sinceVersion = feature =>
  feature->sinceVersionRaw->Nullable.toOption

let untilVersion = feature =>
  feature->untilVersionRaw->Nullable.toOption

let toJsonObject = feature => {
  let payload = Dict.make()
  payload->Dict.set("name", JSON.Encode.string(feature->name))
  switch feature->sinceVersion {
  | Some(value) => payload->Dict.set("sinceVersion", JSON.Encode.string(value))
  | None => ()
  }
  switch feature->untilVersion {
  | Some(value) => payload->Dict.set("untilVersion", JSON.Encode.string(value))
  | None => ()
  }
  payload
}

let toJSON = feature =>
  feature->toJsonObject->JSON.Encode.object

let toJSONFromUnknown = value =>
  value->unsafeFromUnknown->toJSON
