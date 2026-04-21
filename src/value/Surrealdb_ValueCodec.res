// src/bindings/Surrealdb_ValueCodec.res — SurrealDB ValueCodec interface binding.
// Concern: model the public SDK codec interface used by DriverOptions.codecs.
// Source: node_modules/surrealdb/dist/surrealdb.d.ts — ValueCodec and
// CodecFactory are part of the public constructor surface.
type t
type factory = Surrealdb_CborCodec.options => t

external fromCborCodec: Surrealdb_CborCodec.t => t = "%identity"

@send external encode: (t, 'value) => Js.TypedArray2.Uint8Array.t = "encode"
@send external decode: (t, Js.TypedArray2.Uint8Array.t) => 'value = "decode"
@get external byteLength: Js.TypedArray2.Uint8Array.t => int = "length"

let cborFactory: factory = options =>
  options->Surrealdb_CborCodec.makeRaw->fromCborCodec

let encodedLength = bytes =>
  bytes->byteLength
