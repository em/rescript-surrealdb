// src/bindings/Surrealdb_GeometryPoint.res — SurrealDB GeometryPoint binding.
// Concern: bind the GeometryPoint class from the surrealdb SDK.
// Source: https://surrealdb.com/docs/languages/javascript/api/values/geometry —
// GeometryPoint is a 2D point with coordinates and GeoJSON serialization.
type t
type ctor

type coordinate =
  | Float(float)
  | Decimal(Surrealdb_Decimal.t)

@module("surrealdb") @new external makeRaw: array<unknown> => t = "GeometryPoint"
@module("surrealdb") external ctor: ctor = "GeometryPoint"
external unsafeFromUnknown: unknown => t = "%identity"
external unsafeFloatToUnknown: float => unknown = "%identity"
external unsafeDecimalToUnknown: Surrealdb_Decimal.t => unknown = "%identity"
external asGeometry: t => Surrealdb_Geometry.t = "%identity"
external unsafeJsonFromUnknown: unknown => JSON.t = "%identity"

@get external point: t => array<float> = "point"
@get external coordinates: t => array<float> = "coordinates"
@send external toString: t => string = "toString"
@send external equals: (t, unknown) => bool = "equals"
@send external clone: t => t = "clone"
@send external matches: (t, Surrealdb_Geometry.t) => bool = "is"
@send external toJSONRaw: t => unknown = "toJSON"

let coordinateToUnknown = coordinate =>
  switch coordinate {
  | Float(value) => unsafeFloatToUnknown(value)
  | Decimal(value) => unsafeDecimalToUnknown(value)
  }

let make = (~longitude, ~latitude) =>
  makeRaw([longitude->coordinateToUnknown, latitude->coordinateToUnknown])

let toJSON = value => value->toJSONRaw->unsafeJsonFromUnknown

let isInstance = value =>
  JsTypeReflection.instanceOfClass(~instance=value, ~class_=ctor)

let fromUnknown = value =>
  if isInstance(value) {
    Some(unsafeFromUnknown(value))
  } else {
    None
  }
