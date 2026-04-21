type t
type ctor

let fromString: string => t
let fromBuffer: ArrayBuffer.t => t
let fromUint8Array: Js.TypedArray2.Uint8Array.t => t
let ctor: ctor
let toString: t => string
let equals: (t, unknown) => bool
let toJSON: t => string
let toUint8Array: t => Js.TypedArray2.Uint8Array.t
let toBuffer: t => ArrayBuffer.t
let uint8ArrayLength: Js.TypedArray2.Uint8Array.t => int
let byteLength: ArrayBuffer.t => int
let v4: unit => t
let v7: unit => t
let bytesLength: t => int
let bufferByteLength: t => int
let isInstance: unknown => bool
let fromUnknown: unknown => option<t>
