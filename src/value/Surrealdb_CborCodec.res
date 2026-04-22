// src/bindings/Surrealdb_CborCodec.res — SurrealDB CBOR codec binding.
// Concern: bind the CborCodec class exported by the surrealdb SDK.
// Source: surrealdb.d.ts — CborCodec implements ValueCodec with constructor
// options and .encode() / .decode().
type t
type options
type decodeError = Surrealdb_CodecDecode.error =
  | RejectedValue(unknown)

@obj
external makeOptions: (
  ~useNativeDates: bool=?,
  ~valueEncodeVisitor: (unknown => unknown)=?,
  ~valueDecodeVisitor: (unknown => unknown)=?,
  unit,
) => options = ""

@module("surrealdb") @new
external makeRaw: options => t = "CborCodec"

@send external encode: (t, unknown) => Js.TypedArray2.Uint8Array.t = "encode"
@send external decodeRaw: (t, Js.TypedArray2.Uint8Array.t) => unknown = "decode"

let make = (~useNativeDates=?, ~valueEncodeVisitor=?, ~valueDecodeVisitor=?, ()) =>
  makeRaw(makeOptions(~useNativeDates?, ~valueEncodeVisitor?, ~valueDecodeVisitor?, ()))

let default = () => make(())

let decodeUnknown = (codec, bytes) =>
  codec->decodeRaw(bytes)

let decodeWith = (codec, bytes, decodeFn) =>
  codec->decodeUnknown(bytes)->Surrealdb_CodecDecode.decodeWithUnknown(decodeFn)
