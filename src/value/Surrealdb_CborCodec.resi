type t
type options
type decodeError = Surrealdb_CodecDecode.error =
  | RejectedValue(unknown)

let makeOptions: (
  ~useNativeDates: bool=?,
  ~valueEncodeVisitor: (unknown => unknown)=?,
  ~valueDecodeVisitor: (unknown => unknown)=?,
  unit,
) => options
let makeRaw: options => t
let encode: (t, unknown) => Js.TypedArray2.Uint8Array.t
let make: (
  ~useNativeDates: bool=?,
  ~valueEncodeVisitor: (unknown => unknown)=?,
  ~valueDecodeVisitor: (unknown => unknown)=?,
  unit,
) => t
let default: unit => t
let decodeUnknown: (t, Js.TypedArray2.Uint8Array.t) => unknown
let decodeWith: (t, Js.TypedArray2.Uint8Array.t, unknown => option<'value>) => result<'value, decodeError>
