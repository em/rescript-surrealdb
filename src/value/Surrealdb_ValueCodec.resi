type t
type factory = Surrealdb_CborCodec.options => t

let fromCborCodec: Surrealdb_CborCodec.t => t
let encode: (t, 'value) => Js.TypedArray2.Uint8Array.t
let decode: (t, Js.TypedArray2.Uint8Array.t) => 'value
let byteLength: Js.TypedArray2.Uint8Array.t => int
let cborFactory: factory
let encodedLength: Js.TypedArray2.Uint8Array.t => int
