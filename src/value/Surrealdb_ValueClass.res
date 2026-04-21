// src/bindings/Surrealdb_ValueClass.res — SurrealDB Value base-class binding.
// Concern: preserve the exported abstract Value class as a public runtime type
// instead of treating only concrete subclasses as bindable.
type t
type ctor

@module("surrealdb") external ctor: ctor = "Value"
external unsafeFromUnknown: unknown => t = "%identity"
external toUnknown: t => unknown = "%identity"

@send external equals: (t, unknown) => bool = "equals"
@send external toJSON: t => unknown = "toJSON"
@send external toString: t => string = "toString"

let isInstance = value =>
  JsTypeReflection.instanceOfClass(~instance=value, ~class_=ctor)

let fromUnknown = value =>
  if isInstance(value) {
    Some(unsafeFromUnknown(value))
  } else {
    None
  }
