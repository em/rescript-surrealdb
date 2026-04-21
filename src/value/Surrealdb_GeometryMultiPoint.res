// src/bindings/Surrealdb_GeometryMultiPoint.res — SurrealDB GeometryMultiPoint binding.
// Concern: bind the GeometryMultiPoint class from the surrealdb SDK.
// Source: https://surrealdb.com/docs/languages/javascript/api/values/geometry —
// GeometryMultiPoint is a collection of GeometryPoint values.
type t
type ctor

@module("surrealdb") @new external makeRaw: array<Surrealdb_GeometryPoint.t> => t = "GeometryMultiPoint"
@module("surrealdb") external ctor: ctor = "GeometryMultiPoint"
external unsafeFromUnknown: unknown => t = "%identity"
external asGeometry: t => Surrealdb_Geometry.t = "%identity"
external unsafeJsonFromUnknown: unknown => JSON.t = "%identity"

@get external points: t => array<Surrealdb_GeometryPoint.t> = "points"
@get external coordinates: t => array<array<float>> = "coordinates"
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
