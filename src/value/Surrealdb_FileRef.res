// src/bindings/Surrealdb_FileRef.res — SurrealDB FileRef value binding.
// Concern: bind the FileRef class from the surrealdb SDK.
// Source: https://surrealdb.com/docs/languages/javascript/api/values/file-ref — FileRef
// exposes bucket, key, toString, toJSON, and equals for file-field values.
type t
type ctor

@module("surrealdb") @new external make: (string, string) => t = "FileRef"
@module("surrealdb") external ctor: ctor = "FileRef"
external unsafeFromUnknown: unknown => t = "%identity"

@get external bucket: t => string = "bucket"
@get external key: t => string = "key"
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
