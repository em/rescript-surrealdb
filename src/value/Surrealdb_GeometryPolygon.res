// src/bindings/Surrealdb_GeometryPolygon.res — SurrealDB GeometryPolygon binding.
// Concern: bind the GeometryPolygon class from the surrealdb SDK.
// Source: https://surrealdb.com/docs/languages/javascript/api/values/geometry —
// GeometryPolygon is an outer GeometryLine plus optional hole lines.
type t
type ctor

@module("surrealdb") @new external makeRaw: array<Surrealdb_GeometryLine.t> => t = "GeometryPolygon"
@module("surrealdb") external ctor: ctor = "GeometryPolygon"
external unsafeFromUnknown: unknown => t = "%identity"
external asGeometry: t => Surrealdb_Geometry.t = "%identity"
external unsafeJsonFromUnknown: unknown => JSON.t = "%identity"

@get external polygon: t => array<Surrealdb_GeometryLine.t> = "polygon"
@get external coordinates: t => array<array<array<float>>> = "coordinates"
@send external toString: t => string = "toString"
@send external equals: (t, unknown) => bool = "equals"
@send external clone: t => t = "clone"
@send external matches: (t, Surrealdb_Geometry.t) => bool = "is"
@send external toJSONRaw: t => unknown = "toJSON"

let make = (~outerBoundary, ~holes=[]) =>
  makeRaw(Array.concat([outerBoundary], holes))

let toJSON = value => value->toJSONRaw->unsafeJsonFromUnknown

let isInstance = value =>
  JsTypeReflection.instanceOfClass(~instance=value, ~class_=ctor)

let fromUnknown = value =>
  if isInstance(value) {
    Some(unsafeFromUnknown(value))
  } else {
    None
  }
