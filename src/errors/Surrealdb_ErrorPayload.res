// src/bindings/Surrealdb_ErrorPayload.res — typed foreign payload classifier for
// error surfaces that the SDK leaves open as unknown.
type rec t =
  | Undefined
  | Null
  | String(string)
  | Boolean(bool)
  | Number(float)
  | BigInt(BigInt.t)
  | Function
  | Symbol
  | SurrealValue(Surrealdb_Value.t)
  | Array(array<t>)
  | Object(dict<t>)
  | OpaqueObject

external asNullable: unknown => Nullable.t<unknown> = "%identity"
external asString: unknown => string = "%identity"
external asBool: unknown => bool = "%identity"
external asFloat: unknown => float = "%identity"
external asBigInt: unknown => BigInt.t = "%identity"
external asArray: unknown => array<unknown> = "%identity"

let rec classifyDict = values => {
  let result = Dict.make()
  values->Dict.toArray->Array.forEach(((key, value)) => result->Dict.set(key, fromUnknown(value)))
  result
} and fromUnknown = raw =>
  switch Surrealdb_Value.classifyTypedValue(raw) {
  | Some(value) => SurrealValue(value)
  | None =>
    switch typeof(raw) {
    | #undefined => Undefined
    | #string => String(asString(raw))
    | #boolean => Boolean(asBool(raw))
    | #number => Number(asFloat(raw))
    | #bigint => BigInt(asBigInt(raw))
    | #function => Function
    | #symbol => Symbol
    | #object =>
      if Nullable.isNullable(asNullable(raw)) {
        Null
      } else if Array.isArray(raw) {
        Array(asArray(raw)->Array.map(fromUnknown))
      } else {
        OpaqueObject
      }
    }
  } 

let foreignPayload = (payloadType, value) =>
  JSON.Encode.object(
    switch value {
    | Some(payloadValue) =>
      Dict.fromArray([
        ("foreignPayloadType", JSON.Encode.string(payloadType)),
        ("value", payloadValue),
      ])
    | None => Dict.fromArray([("foreignPayloadType", JSON.Encode.string(payloadType))])
    },
  )

let rec objectJson = entries => {
  let result = Dict.make()
  entries->Dict.toArray->Array.forEach(((key, value)) => result->Dict.set(key, value->toJSON))
  result
} and toJSON = payload =>
  switch payload {
  | Undefined => foreignPayload("undefined", None)
  | Null => foreignPayload("null", None)
  | String(value) => foreignPayload("string", Some(JSON.Encode.string(value)))
  | Boolean(value) => foreignPayload("boolean", Some(JSON.Encode.bool(value)))
  | Number(value) => foreignPayload("number", Some(JSON.Encode.float(value)))
  | BigInt(value) => foreignPayload("bigint", Some(JSON.Encode.string(value->BigInt.toString)))
  | Function => foreignPayload("function", None)
  | Symbol => foreignPayload("symbol", None)
  | SurrealValue(value) => foreignPayload("surrealValue", Some(value->Surrealdb_Value.toJSON))
  | Array(values) => foreignPayload("array", Some(JSON.Encode.array(values->Array.map(toJSON))))
  | Object(values) => foreignPayload("object", Some(JSON.Encode.object(values->objectJson)))
  | OpaqueObject => foreignPayload("object", None)
  }
