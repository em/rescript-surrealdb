// src/bindings/Surrealdb_GeometryMultiPolygon.res — SurrealDB GeometryMultiPolygon binding.
// Concern: bind the GeometryMultiPolygon class from the surrealdb SDK.
// Source: https://surrealdb.com/docs/languages/javascript/api/values/geometry —
// GeometryMultiPolygon is a collection of GeometryPolygon values.
type t
type ctor

@module("surrealdb") @new external makeRaw: array<Surrealdb_GeometryPolygon.t> => t = "GeometryMultiPolygon"
@module("surrealdb") external ctor: ctor = "GeometryMultiPolygon"
external unsafeFromUnknown: unknown => t = "%identity"
external asGeometry: t => Surrealdb_Geometry.t = "%identity"
external unsafeJsonFromUnknown: unknown => JSON.t = "%identity"

@get external polygons: t => array<Surrealdb_GeometryPolygon.t> = "polygons"
@get external coordinates: t => array<array<array<array<float>>>> = "coordinates"
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
