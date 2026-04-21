// src/bindings/Surrealdb_Engine.res — SurrealDB engine binding.
// Concern: bind the public SurrealEngine interface returned by exported engine
// factories so low-level transport surfaces are available to the rewrite.
type t

external toUnknown: t => unknown = "%identity"

@send external close: t => promise<unit> = "close"
@send external ready: t => unit = "ready"
@get external featuresSet: t => Set.t<Surrealdb_Feature.t> = "features"

@scope("Array") @val external arrayFromSet: Set.t<'a> => array<'a> = "from"

let features = engine =>
  engine->featuresSet->arrayFromSet
