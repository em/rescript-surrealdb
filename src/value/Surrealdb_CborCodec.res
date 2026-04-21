// src/bindings/Surrealdb_CborCodec.res — SurrealDB CBOR codec binding.
// Concern: bind the CborCodec class exported by the surrealdb SDK.
// Source: surrealdb.d.ts — CborCodec implements ValueCodec with constructor
// options and .encode() / .decode().
type t
type options

@obj
external makeOptions: (
  ~useNativeDates: bool=?,
  ~valueEncodeVisitor: (unknown => unknown)=?,
  ~valueDecodeVisitor: (unknown => unknown)=?,
  unit,
) => options = ""

@module("surrealdb") @new
external makeRaw: options => t = "CborCodec"

@send external encode: (t, 'value) => Js.TypedArray2.Uint8Array.t = "encode"
@send external decode: (t, Js.TypedArray2.Uint8Array.t) => 'value = "decode"

let make = (~useNativeDates=?, ~valueEncodeVisitor=?, ~valueDecodeVisitor=?, ()) =>
  makeRaw(makeOptions(~useNativeDates?, ~valueEncodeVisitor?, ~valueDecodeVisitor?, ()))

let default = () => make(())

let decodeUnknown = (codec, bytes) =>
  codec->decode(bytes)
