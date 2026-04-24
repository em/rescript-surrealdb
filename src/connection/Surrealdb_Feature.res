// src/bindings/Surrealdb_Feature.res — SurrealDB feature binding.
// Concern: bind Feature instances surfaced through SDK errors and engine state.
// Source: surrealdb.d.ts — Feature has .name, .sinceVersion, .untilVersion, and
// .supports(version), but is not exported as a top-level constructor.
type t
type ctor
type collection

external unsafeFromUnknown: unknown => t = "%identity"
@module("surrealdb") external all: collection = "Features"
@get external liveQueries_: collection => t = "LiveQueries"
@get external ctor: t => ctor = "constructor"

@get external name: t => string = "name"
@get external sinceVersionRaw: t => Nullable.t<string> = "sinceVersion"
@get external untilVersionRaw: t => Nullable.t<string> = "untilVersion"
@send external supports: (t, string) => bool = "supports"

let sinceVersion = feature =>
  feature->sinceVersionRaw->Nullable.toOption

let untilVersion = feature =>
  feature->untilVersionRaw->Nullable.toOption

let toJsonObject = feature =>
  [
    [("name", JSON.Encode.string(feature->name))],
    switch feature->sinceVersion {
    | Some(value) => [("sinceVersion", JSON.Encode.string(value))]
    | None => []
    },
    switch feature->untilVersion {
    | Some(value) => [("untilVersion", JSON.Encode.string(value))]
    | None => []
    },
  ]
  ->Belt.Array.concatMany
  ->Dict.fromArray

let toJSON = feature =>
  feature->toJsonObject->JSON.Encode.object

let runtimeCtor = all->liveQueries_->ctor

let isInstance = value =>
  JsTypeReflection.instanceOfClass(~instance=value, ~class_=runtimeCtor)

let fromUnknown = value =>
  if value->isInstance {
    Some(value->unsafeFromUnknown)
  } else {
    None
  }
