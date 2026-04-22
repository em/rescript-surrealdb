type t
type factory = Surrealdb_CborCodec.options => t
type decodeError = Surrealdb_CodecDecode.error =
  | RejectedValue(unknown)

let fromCborCodec: Surrealdb_CborCodec.t => t
let encode: (t, unknown) => Js.TypedArray2.Uint8Array.t
let decodeUnknown: (t, Js.TypedArray2.Uint8Array.t) => unknown
let decodeWith: (t, Js.TypedArray2.Uint8Array.t, unknown => option<'value>) => result<'value, decodeError>
let byteLength: Js.TypedArray2.Uint8Array.t => int
let cborFactory: factory
let encodedLength: Js.TypedArray2.Uint8Array.t => int
