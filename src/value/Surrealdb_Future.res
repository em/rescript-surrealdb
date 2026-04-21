// src/bindings/Surrealdb_Future.res — SurrealDB Future value binding.
// Concern: bind the deprecated-but-exported Future class from the surrealdb SDK.
// Source: surrealdb.d.ts — Future extends Value with constructor(body), .body,
// .toJSON(), .toString(), and .equals().
type t
type ctor

@module("surrealdb") @new external make: string => t = "Future"
@module("surrealdb") external ctor: ctor = "Future"
external unsafeFromUnknown: unknown => t = "%identity"

@get external body: t => string = "body"
@send external toJSON: t => string = "toJSON"
@send external toString: t => string = "toString"
@send external equals: (t, unknown) => bool = "equals"

let isInstance = value =>
  JsTypeReflection.instanceOfClass(~instance=value, ~class_=ctor)

let fromUnknown = value =>
  if isInstance(value) {
    Some(unsafeFromUnknown(value))
  } else {
    None
  }
