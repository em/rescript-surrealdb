// src/bindings/Surrealdb_Table.res — SurrealDB Table value binding.
// Concern: bind the Table class from the surrealdb SDK.
// Source: surrealdb.d.ts — Table<Tb> extends Value. Represents a table reference
// with a typed .name accessor returning the unescaped table name.
type t
type ctor

@module("surrealdb") @new external make: string => t = "Table"
@module("surrealdb") external ctor: ctor = "Table"
external unsafeFromUnknown: unknown => t = "%identity"

@get external name: t => string = "name"
@send external toString: t => string = "toString"
@send external equals: (t, unknown) => bool = "equals"
@send external toJSON: t => string = "toJSON"

let isInstance = value =>
  JsTypeReflection.instanceOfClass(~instance=value, ~class_=ctor)

let fromUnknown = value =>
  if isInstance(value) {
    Some(unsafeFromUnknown(value))
  } else {
    None
  }
