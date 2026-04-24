let toUnknown = SurrealdbTestCasts.toUnknown
let intToUnknown = SurrealdbTestCasts.intToUnknown
let stringToUnknown = SurrealdbTestCasts.stringToUnknown

let decodeObject = raw =>
  switch raw->Surrealdb_Value.fromUnknown {
  | Object(entries) => Some(entries)
  | _ => None
  }

let decodedObjectJson = decoded =>
  switch decoded {
  | Ok(entries) =>
    Surrealdb_Value.Object(entries)
    ->Surrealdb_Value.toJSON
    ->JSON.stringifyAny
    ->Option.getOr("")
  | Error(_) => "<decode-error>"
  }

Vitest.describe("SurrealDB binding values", () => {
  Vitest.test("Future values classify and stringify through Surrealdb_Value", t => {
    let future = Surrealdb_Future.make("time::now()")
    let value = future->toUnknown->Surrealdb_Value.fromUnknown
    t->Vitest.expect(value->Surrealdb_Value.toText)->Vitest.Expect.toBe("<future> time::now()")
    t->Vitest.expect(value->Surrealdb_Value.toJSON->JSON.stringifyAny->Option.getOr(""))->Vitest.Expect.toBe(
      "\"<future> time::now()\"",
    )
  })

  Vitest.test("CborCodec decodeWith requires explicit decode evidence", t => {
    let codec = Surrealdb_CborCodec.default()
    let payload: dict<unknown> = Dict.make()
    payload->Dict.set("count", intToUnknown(3))
    payload->Dict.set("name", stringToUnknown("alpha"))
    let bytes = codec->Surrealdb_CborCodec.encode(payload->toUnknown)
    let decoded = codec->Surrealdb_CborCodec.decodeWith(bytes, decodeObject)
    let rejected =
      codec
      ->Surrealdb_CborCodec.decodeWith(bytes, raw =>
          switch raw->Surrealdb_Value.fromUnknown {
          | String(value) => Some(value)
          | _ => None
          }
        )

    t->Vitest.expect((
      decoded->decodedObjectJson,
      switch rejected {
      | Error(Surrealdb_CborCodec.RejectedValue(_)) => true
      | Ok(_) => false
      },
    ))->Vitest.Expect.toEqual(("{\"count\":3,\"name\":\"alpha\"}", true))
  })

  Vitest.test("ValueCodec decodeWith preserves the same checked decode contract", t => {
    let codec = Surrealdb_CborCodec.default()->Surrealdb_ValueCodec.fromCborCodec
    let payload: dict<unknown> = Dict.make()
    payload->Dict.set("count", intToUnknown(7))
    let bytes = codec->Surrealdb_ValueCodec.encode(payload->toUnknown)

    t->Vitest.expect((
      codec->Surrealdb_ValueCodec.decodeWith(bytes, decodeObject)->decodedObjectJson,
      switch codec->Surrealdb_ValueCodec.decodeWith(bytes, _raw => None) {
      | Error(Surrealdb_ValueCodec.RejectedValue(_)) => true
      | Ok(_) => false
      },
    ))->Vitest.Expect.toEqual(("{\"count\":7}", true))
  })

  Vitest.test("bigint values stay explicit instead of collapsing into None", t => {
    let value =
      Surrealdb_Duration.fromString("1ns")
      ->Surrealdb_Duration.nanoseconds
      ->toUnknown
      ->Surrealdb_Value.fromUnknown

    t->Vitest.expect((
      value->Surrealdb_Value.toText,
      value->Surrealdb_Value.toJSON->JSON.stringifyAny->Option.getOr(""),
    ))->Vitest.Expect.toEqual(("1n", "{\"unsupported\":\"bigint\",\"value\":\"1\"}"))
  })
})
