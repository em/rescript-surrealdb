type t
type options

let makeOptions: (
  ~useNativeDates: bool=?,
  ~valueEncodeVisitor: (unknown => unknown)=?,
  ~valueDecodeVisitor: (unknown => unknown)=?,
  unit,
) => options
let makeRaw: options => t
let encode: (t, 'value) => Js.TypedArray2.Uint8Array.t
let decode: (t, Js.TypedArray2.Uint8Array.t) => 'value
let make: (
  ~useNativeDates: bool=?,
  ~valueEncodeVisitor: (unknown => unknown)=?,
  ~valueDecodeVisitor: (unknown => unknown)=?,
  unit,
) => t
let default: unit => t
let decodeUnknown: (t, Js.TypedArray2.Uint8Array.t) => 'value
