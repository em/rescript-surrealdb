// src/bindings/Surrealdb_GeometryLine.res — SurrealDB GeometryLine binding.
// Concern: bind the GeometryLine class from the surrealdb SDK.
// Source: https://surrealdb.com/docs/languages/javascript/api/values/geometry —
// GeometryLine is a line made from two or more GeometryPoint values.
type t
type ctor

@module("surrealdb") @new external makeRaw: array<Surrealdb_GeometryPoint.t> => t = "GeometryLine"
@module("surrealdb") external ctor: ctor = "GeometryLine"
external unsafeFromUnknown: unknown => t = "%identity"
external asGeometry: t => Surrealdb_Geometry.t = "%identity"
external unsafeJsonFromUnknown: unknown => JSON.t = "%identity"

@get external line: t => array<Surrealdb_GeometryPoint.t> = "line"
@get external coordinates: t => array<array<float>> = "coordinates"
@send external close: t => unit = "close"
@send external toString: t => string = "toString"
@send external equals: (t, unknown) => bool = "equals"
@send external clone: t => t = "clone"
@send external matches: (t, Surrealdb_Geometry.t) => bool = "is"
@send external toJSONRaw: t => unknown = "toJSON"

let make = (~first, ~second, ~rest=[]) =>
  makeRaw(Array.concat([first, second], rest))

let toJSON = value => value->toJSONRaw->unsafeJsonFromUnknown

let isInstance = value =>
  JsTypeReflection.instanceOfClass(~instance=value, ~class_=ctor)

let fromUnknown = value =>
  if isInstance(value) {
    Some(unsafeFromUnknown(value))
  } else {
    None
  }
