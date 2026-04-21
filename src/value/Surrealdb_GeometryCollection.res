// src/bindings/Surrealdb_GeometryCollection.res — SurrealDB GeometryCollection binding.
// Concern: bind the GeometryCollection class from the surrealdb SDK.
// Source: https://surrealdb.com/docs/languages/javascript/api/values/geometry —
// GeometryCollection is a mixed collection of Geometry values.
type t
type ctor

@module("surrealdb") @new external makeRaw: array<Surrealdb_Geometry.t> => t = "GeometryCollection"
@module("surrealdb") external ctor: ctor = "GeometryCollection"
external unsafeFromUnknown: unknown => t = "%identity"
external asGeometry: t => Surrealdb_Geometry.t = "%identity"
external unsafeJsonFromUnknown: unknown => JSON.t = "%identity"

@get external collection: t => array<Surrealdb_Geometry.t> = "collection"
@get external geometries: t => array<JSON.t> = "geometries"
@send external toString: t => string = "toString"
@send external equals: (t, unknown) => bool = "equals"
@send external clone: t => t = "clone"
@send external matches: (t, Surrealdb_Geometry.t) => bool = "is"
@send external toJSONRaw: t => unknown = "toJSON"

let make = (~first, ~rest=[]) =>
  makeRaw(Array.concat([first], rest))

let toJSON = value => value->toJSONRaw->unsafeJsonFromUnknown

let isInstance = value =>
  JsTypeReflection.instanceOfClass(~instance=value, ~class_=ctor)

let fromUnknown = value =>
  if isInstance(value) {
    Some(unsafeFromUnknown(value))
  } else {
    None
  }
