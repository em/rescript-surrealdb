// src/bindings/Surrealdb_ValueCodec.res — SurrealDB ValueCodec interface binding.
// Concern: model the public SDK codec interface used by DriverOptions.codecs.
// Source: node_modules/surrealdb/dist/surrealdb.d.ts — ValueCodec and
// CodecFactory are part of the public constructor surface.
type t
type factory = Surrealdb_CborCodec.options => t
type decodeError = Surrealdb_CodecDecode.error =
  | RejectedValue(unknown)

external fromCborCodec: Surrealdb_CborCodec.t => t = "%identity"

@send external encode: (t, unknown) => Js.TypedArray2.Uint8Array.t = "encode"
@send external decodeRaw: (t, Js.TypedArray2.Uint8Array.t) => unknown = "decode"
@get external byteLength: Js.TypedArray2.Uint8Array.t => int = "length"

let cborFactory: factory = options =>
  options->Surrealdb_CborCodec.makeRaw->fromCborCodec

let decodeUnknown = (codec, bytes) =>
  codec->decodeRaw(bytes)

let decodeWith = (codec, bytes, decodeFn) =>
  codec->decodeUnknown(bytes)->Surrealdb_CodecDecode.decodeWithUnknown(decodeFn)

let encodedLength = bytes =>
  bytes->byteLength
