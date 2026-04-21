// src/bindings/Surrealdb_Uuid.res — SurrealDB Uuid value binding.
// Concern: bind the Uuid class from the surrealdb SDK.
// Source: surrealdb.d.ts — Uuid extends Value. UUID with constructors from string or
// binary. Static generators .v4() and .v7().
type t
type ctor

@module("surrealdb") @new external fromString: string => t = "Uuid"
@module("surrealdb") @new external fromBuffer: ArrayBuffer.t => t = "Uuid"
@module("surrealdb") @new external fromUint8Array: Js.TypedArray2.Uint8Array.t => t = "Uuid"
@module("surrealdb") external ctor: ctor = "Uuid"
external unsafeFromUnknown: unknown => t = "%identity"

@send external toString: t => string = "toString"
@send external equals: (t, unknown) => bool = "equals"
@send external toJSON: t => string = "toJSON"
@send external toUint8Array: t => Js.TypedArray2.Uint8Array.t = "toUint8Array"
@send external toBuffer: t => ArrayBuffer.t = "toBuffer"

@get external uint8ArrayLength: Js.TypedArray2.Uint8Array.t => int = "length"
@get external byteLength: ArrayBuffer.t => int = "byteLength"

@module("surrealdb") @scope("Uuid") external v4: unit => t = "v4"
@module("surrealdb") @scope("Uuid") external v7: unit => t = "v7"

let bytesLength = value =>
  value->toUint8Array->uint8ArrayLength

let bufferByteLength = value =>
  value->toBuffer->byteLength

let isInstance = value =>
  JsTypeReflection.instanceOfClass(~instance=value, ~class_=ctor)

let fromUnknown = value =>
  if isInstance(value) {
    Some(unsafeFromUnknown(value))
  } else {
    None
  }
