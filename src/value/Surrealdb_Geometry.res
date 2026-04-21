// src/bindings/Surrealdb_Geometry.res — SurrealDB Geometry value binding.
// Concern: bind the abstract Geometry base class from the surrealdb SDK.
// Source: https://surrealdb.com/docs/languages/javascript/api/values/geometry — all
// geometry values expose toJSON, toString, equals, and clone, and serialize to
// GeoJSON-shaped objects.
type t
type ctor

@module("surrealdb") external ctor: ctor = "Geometry"
external unsafeFromUnknown: unknown => t = "%identity"
external unsafeJsonFromUnknown: unknown => JSON.t = "%identity"

@send external toString: t => string = "toString"
@send external equals: (t, unknown) => bool = "equals"
@send external clone: t => t = "clone"
@send external matches: (t, t) => bool = "is"
@send external toJSONRaw: t => unknown = "toJSON"

let toJSON = value => value->toJSONRaw->unsafeJsonFromUnknown

let isInstance = value =>
  JsTypeReflection.instanceOfClass(~instance=value, ~class_=ctor)

let fromUnknown = value =>
  if isInstance(value) {
    Some(unsafeFromUnknown(value))
  } else {
    None
  }
