// src/bindings/Surrealdb_StringRecordId.res — SurrealDB StringRecordId value binding.
// Concern: bind the StringRecordId class from the surrealdb SDK.
// Source: surrealdb.d.ts — StringRecordId extends Value. String-represented record ID.
// Constructor takes a string, StringRecordId, or RecordId.
type t
type ctor

@module("surrealdb") @new external fromString: string => t = "StringRecordId"
@module("surrealdb") @new external fromRecordId: Surrealdb_RecordId.t => t = "StringRecordId"
@module("surrealdb") @new external fromStringRecordId: t => t = "StringRecordId"
@module("surrealdb") external ctor: ctor = "StringRecordId"
external unsafeFromUnknown: unknown => t = "%identity"

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
