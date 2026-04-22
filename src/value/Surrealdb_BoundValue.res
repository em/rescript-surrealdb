// src/bindings/Surrealdb_BoundValue.res — typed classifier for range-bound payloads.
// Concern: classify raw bound payloads without leaking unknown through the public
// RangeBound surface and without depending on the full recursive Value algebra.
type rec t =
  | Undefined
  | Null
  | Bool(bool)
  | Int(int)
  | Float(float)
  | String(string)
  | BigInt(BigInt.t)
  | Function
  | Symbol
  | ValueClass(Surrealdb_ValueClass.t)
  | Array(array<t>)
  | Object(dict<t>)

external asNullable: unknown => Nullable.t<unknown> = "%identity"
external asString: unknown => string = "%identity"
external asBool: unknown => bool = "%identity"
external asFloat: unknown => float = "%identity"
external asInt: unknown => int = "%identity"
external asBigInt: unknown => BigInt.t = "%identity"
external asArray: unknown => array<unknown> = "%identity"
external asDict: unknown => dict<unknown> = "%identity"

let rec fromUnknown = raw =>
  switch Surrealdb_ValueClass.fromUnknown(raw) {
  | Some(value) => ValueClass(value)
  | None =>
    switch typeof(raw) {
    | #undefined => Undefined
    | #string => String(asString(raw))
    | #boolean => Bool(asBool(raw))
    | #number =>
      let value = asFloat(raw)
      if Math.floor(value) == value && value > -2147483648.0 && value < 2147483648.0 {
        Int(asInt(raw))
      } else {
        Float(value)
      }
    | #bigint => BigInt(asBigInt(raw))
    | #function => Function
    | #symbol => Symbol
    | #object =>
      if Nullable.isNullable(asNullable(raw)) {
        Null
      } else if Array.isArray(raw) {
        Array(asArray(raw)->Array.map(fromUnknown))
      } else {
        let result = Dict.make()
        asDict(raw)->Dict.toArray->Array.forEach(((key, value)) => result->Dict.set(key, fromUnknown(value)))
        Object(result)
      }
    }
  }

let rec toText = value =>
  switch value {
  | Undefined => ""
  | Null => "null"
  | Bool(raw) => raw ? "true" : "false"
  | Int(raw) => raw->Int.toString
  | Float(raw) => raw->Float.toString
  | String(raw) => raw
  | BigInt(raw) => `${raw->BigInt.toString}n`
  | Function => "<function>"
  | Symbol => "<symbol>"
  | ValueClass(raw) => raw->Surrealdb_ValueClass.toString
  | Array(items) => items->Array.map(toText)->Array.join(", ")
  | Object(entries) =>
    entries
    ->Dict.toArray
    ->Array.map(((key, item)) => `${key}: ${item->toText}`)
    ->Array.join("; ")
  }

let rec toJSON = value =>
  switch value {
  | Undefined => JSON.Encode.object(Dict.fromArray([("boundValueType", JSON.Encode.string("undefined"))]))
  | Null => JSON.Encode.null
  | Bool(raw) => JSON.Encode.bool(raw)
  | Int(raw) => JSON.Encode.int(raw)
  | Float(raw) => JSON.Encode.float(raw)
  | String(raw) => JSON.Encode.string(raw)
  | BigInt(raw) =>
    JSON.Encode.object(
      Dict.fromArray([
        ("boundValueType", JSON.Encode.string("bigint")),
        ("value", JSON.Encode.string(raw->BigInt.toString)),
      ]),
    )
  | Function => JSON.Encode.object(Dict.fromArray([("boundValueType", JSON.Encode.string("function"))]))
  | Symbol => JSON.Encode.object(Dict.fromArray([("boundValueType", JSON.Encode.string("symbol"))]))
  | ValueClass(raw) => raw->Surrealdb_ValueClass.toJSON->fromUnknown->toJSON
  | Array(items) => JSON.Encode.array(items->Array.map(toJSON))
  | Object(entries) =>
    let result = Dict.make()
    entries->Dict.toArray->Array.forEach(((key, item)) => result->Dict.set(key, item->toJSON))
    JSON.Encode.object(result)
  }
