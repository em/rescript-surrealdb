// src/bindings/Surrealdb_CodecDecode.res — shared checked decode boundary logic
// for codec modules that only produce raw unknown values at runtime.
type error =
  | RejectedValue(unknown)

let decodeWithUnknown = (value, decodeFn) =>
  switch decodeFn(value) {
  | Some(decoded) => Ok(decoded)
  | None => Error(RejectedValue(value))
  }
