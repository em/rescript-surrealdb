// src/bindings/Surrealdb_Range.res — SurrealDB Range value binding.
// Concern: bind the generic Range class from the surrealdb SDK.
// Source: https://surrealdb.com/docs/languages/javascript/api/values/range — Range has
// begin/end bounds, toString, toJSON, and equals. The installed d.ts exports Range$1
// as Range at runtime.
type t
type ctor

@module("surrealdb") @new external makeRaw: (option<unknown>, option<unknown>) => t = "Range"
@module("surrealdb") external ctor: ctor = "Range"
external unsafeFromUnknown: unknown => t = "%identity"
external boundToUnknown: Surrealdb_RangeBound.t => unknown = "%identity"

@get external beginRaw: t => option<unknown> = "begin"
@get external endRaw: t => option<unknown> = "end"
@send external toString: t => string = "toString"
@send external equals: (t, unknown) => bool = "equals"
@send external toJSON: t => string = "toJSON"

let make = (~begin=?, ~end=?, ()) =>
  makeRaw(
    begin->Option.map(boundToUnknown),
    end->Option.map(boundToUnknown),
  )

let begin = value =>
  switch beginRaw(value) {
  | Some(bound) => Surrealdb_RangeBound.fromUnknown(bound)
  | None => None
  }

let end_ = value =>
  switch endRaw(value) {
  | Some(bound) => Surrealdb_RangeBound.fromUnknown(bound)
  | None => None
  }

let isInstance = value =>
  JsTypeReflection.instanceOfClass(~instance=value, ~class_=ctor)

let fromUnknown = value =>
  if isInstance(value) {
    Some(unsafeFromUnknown(value))
  } else {
    None
  }
