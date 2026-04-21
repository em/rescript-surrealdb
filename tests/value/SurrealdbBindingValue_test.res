open TestRuntime

external toUnknown: 'a => unknown = "%identity"
external intToUnknown: int => unknown = "%identity"
external stringToUnknown: string => unknown = "%identity"

describe("SurrealDB binding values", () => {
  test("Future values classify and stringify through Surrealdb_Value", () => {
    let future = Surrealdb_Future.make("time::now()")
    let value = future->toUnknown->Surrealdb_Value.fromUnknown
    value->Surrealdb_Value.toText->TestRuntime.Expect.expect->TestRuntime.Expect.toBe("<future> time::now()")
    value->Surrealdb_Value.toJSON->JSON.stringifyAny->Option.getOr("")->TestRuntime.Expect.expect->TestRuntime.Expect.toBe(
      "\"<future> time::now()\"",
    )
  })

  test("CborCodec round-trips plain objects through the value boundary", () => {
    let codec = Surrealdb_CborCodec.default()
    let payload: dict<unknown> = Dict.make()
    payload->Dict.set("count", intToUnknown(3))
    payload->Dict.set("name", stringToUnknown("alpha"))
    let bytes = codec->Surrealdb_CborCodec.encode(payload)
    let decoded = codec->Surrealdb_CborCodec.decodeUnknown(bytes)
    decoded
    ->Surrealdb_Value.fromUnknown
    ->Surrealdb_Value.toJSON
    ->JSON.stringifyAny
    ->Option.getOr("")
    ->TestRuntime.Expect.expect
    ->TestRuntime.Expect.toBe("{\"count\":3,\"name\":\"alpha\"}")
  })
})
