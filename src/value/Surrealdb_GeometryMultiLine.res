// src/bindings/Surrealdb_GeometryMultiLine.res — SurrealDB GeometryMultiLine binding.
// Concern: bind the GeometryMultiLine class from the surrealdb SDK.
// Source: https://surrealdb.com/docs/languages/javascript/api/values/geometry —
// GeometryMultiLine is a collection of GeometryLine values.
type t
type ctor

@module("surrealdb") @new external makeRaw: array<Surrealdb_GeometryLine.t> => t = "GeometryMultiLine"
@module("surrealdb") external ctor: ctor = "GeometryMultiLine"
external unsafeFromUnknown: unknown => t = "%identity"
external asGeometry: t => Surrealdb_Geometry.t = "%identity"
external unsafeJsonFromUnknown: unknown => JSON.t = "%identity"

@get external lines: t => array<Surrealdb_GeometryLine.t> = "lines"
@get external coordinates: t => array<array<array<float>>> = "coordinates"
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
