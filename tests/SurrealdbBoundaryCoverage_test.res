// Concern: exercise public boundary classifiers, closed-union parsing, and typed
// JS-value construction without hand-written JavaScript test stubs.
// Source: surrealdb.d.ts plus the boundary rows in docs/SOUNDNESS_MATRIX.md.
// Boundary: public `unknown` classification, explicit codec rejection, and
// string/number/record constructors that must stay narrower than raw JS values.
// Why this shape: these tests fail if the binding widens closed surfaces back to
// raw strings or loses the explicit foreign-data seam.
// Coverage: docs/SOUNDNESS_MATRIX.md rows for connection status, query type,
// `JsValue`, codec decode, and `Surrealdb_Value.fromUnknown`.
let toUnknown = SurrealdbTestCasts.toUnknown
let dictToUnknown = SurrealdbTestCasts.dictToUnknown
let nullableToUnknown = SurrealdbTestCasts.nullableToUnknown
let intToUnknown = SurrealdbTestCasts.intToUnknown
let floatToUnknown = SurrealdbTestCasts.floatToUnknown
let stringToUnknown = SurrealdbTestCasts.stringToUnknown

@val external symbolForUnknown: (~name: string) => unknown = "Symbol.for"

let jsonText = (~value) =>
  value->JSON.stringifyAny->Option.getOr("")

let classifyText = (~value) =>
  value->toUnknown->Surrealdb_Value.fromUnknown->Surrealdb_Value.toText

let classifyJsonText = (~value) =>
  jsonText(~value=value->toUnknown->Surrealdb_Value.fromUnknown->Surrealdb_Value.toJSON)

Vitest.describe("SurrealDB boundary coverage", () => {
  Vitest.test("closed connection and query enums keep their parse and string surfaces explicit", t => {
    t->Vitest.expect((
      Surrealdb_ConnectionStatus.parse(" connected "),
      Surrealdb_ConnectionStatus.parse("RECONNECTING"),
      Surrealdb_ConnectionStatus.parse("invalid"),
      Surrealdb_QueryType.parse(" live "),
      Surrealdb_QueryType.parse("KILL"),
      Surrealdb_QueryType.parse("invalid"),
      Surrealdb_ConnectionStatus.Connected->Surrealdb_ConnectionStatus.toString,
      Surrealdb_QueryType.Other->Surrealdb_QueryType.toString,
    ))->Vitest.Expect.toEqual((
      Some(Surrealdb_ConnectionStatus.Connected),
      Some(Surrealdb_ConnectionStatus.Reconnecting),
      None,
      Some(Surrealdb_QueryType.Live),
      Some(Surrealdb_QueryType.Kill),
      None,
      "connected",
      "other",
    ))
  })

  Vitest.test("js value constructors and parameter bindings preserve every supported foreign shape", t => {
    let recordId = Surrealdb_RecordId.make("widgets", "alpha")
    let future = Surrealdb_Future.make("time::now()")
    let stringRecordId = Surrealdb_StringRecordId.fromString("widgets:beta")
    let rangeBound = Surrealdb_RangeBound.included(Surrealdb_RangeBound.String("a"))
    let range =
      Surrealdb_Range.make(
        ~begin=rangeBound,
        ~end=Surrealdb_RangeBound.excluded(Surrealdb_RangeBound.String("z")),
        (),
      )
    let recordIdRange =
      Surrealdb_RecordIdRange.make(
        ~table="widgets",
        ~begin=Surrealdb_RangeBound.included(Surrealdb_RangeBound.String("a")),
        ~end=Surrealdb_RangeBound.excluded(Surrealdb_RangeBound.String("z")),
        (),
      )
    let point =
      Surrealdb_GeometryPoint.make(
        ~longitude=Surrealdb_GeometryPoint.Float(1.0),
        ~latitude=Surrealdb_GeometryPoint.Float(2.0),
      )
    let valueClass =
      Surrealdb_DateTime.fromString("2024-01-02T03:04:05Z")
      ->toUnknown
      ->Surrealdb_ValueClass.fromUnknown
      ->Option.getOrThrow
    let bindings =
      Surrealdb_JsValue.bindings([
        ("name", Surrealdb_JsValue.String("alpha")),
        ("count", Surrealdb_JsValue.Int(3)),
        ("ratio", Surrealdb_JsValue.Float(1.5)),
        ("flag", Surrealdb_JsValue.Bool(true)),
        ("record", Surrealdb_JsValue.Record(recordId)),
      ])

    t->Vitest.expect((
      [
        Surrealdb_JsValue.fromParam(Surrealdb_JsValue.String("alpha")),
        Surrealdb_JsValue.fromParam(Surrealdb_JsValue.Int(3)),
        Surrealdb_JsValue.fromParam(Surrealdb_JsValue.Float(1.5)),
        Surrealdb_JsValue.fromParam(Surrealdb_JsValue.Bool(true)),
        Surrealdb_JsValue.fromParam(Surrealdb_JsValue.Record(recordId)),
      ]->Array.map(value => classifyText(~value)),
      classifyText(~value=Surrealdb_JsValue.string("alpha")),
      classifyText(~value=Surrealdb_JsValue.int(3)),
      classifyText(~value=Surrealdb_JsValue.float(1.5)),
      classifyText(~value=Surrealdb_JsValue.bool(true)),
      classifyJsonText(~value=Surrealdb_JsValue.bigInt(9n)),
      classifyText(~value=Surrealdb_JsValue.table(Surrealdb_Table.make("widgets"))),
      classifyText(~value=Surrealdb_JsValue.recordId(recordId)),
      classifyText(~value=Surrealdb_JsValue.dateTime(Surrealdb_DateTime.fromString("2024-01-02T03:04:05Z"))),
      classifyText(~value=Surrealdb_JsValue.uuid(Surrealdb_Uuid.fromString("018cc251-4f5c-7def-b4c6-000000000001"))),
      classifyText(~value=Surrealdb_JsValue.decimal(Surrealdb_Decimal.fromString("12.34"))),
      classifyText(~value=Surrealdb_JsValue.duration(Surrealdb_Duration.fromString("1h30m"))),
      classifyText(~value=Surrealdb_JsValue.fileRef(Surrealdb_FileRef.make("bucket", "key/path"))),
      classifyText(~value=Surrealdb_JsValue.stringRecordId(stringRecordId)),
      classifyText(~value=Surrealdb_JsValue.future(future)),
      classifyText(~value=Surrealdb_JsValue.range(range)),
      classifyText(~value=Surrealdb_JsValue.rangeBound(rangeBound)),
      classifyText(~value=Surrealdb_JsValue.recordIdRange(recordIdRange)),
      classifyText(~value=Surrealdb_JsValue.geometry(point->Surrealdb_GeometryPoint.asGeometry)),
      classifyText(~value=Surrealdb_JsValue.valueClass(valueClass)),
      classifyJsonText(~value=Surrealdb_JsValue.json(JSON.parseOrThrow("{\"ok\":true}"))),
      classifyText(~value=Surrealdb_JsValue.array([Surrealdb_JsValue.string("x"), Surrealdb_JsValue.int(2)])),
      classifyJsonText(~value=Surrealdb_JsValue.object(Dict.fromArray([("left", Surrealdb_JsValue.string("x"))]))),
      bindings->Dict.toArray->Array.length,
      bindings->Dict.get("record")->Option.map(value => classifyText(~value)),
      Surrealdb_JsValue.emptyBindings->Dict.toArray->Array.length,
    ))->Vitest.Expect.toEqual((
      ["alpha", "3", "1.5", "true", "widgets:alpha"],
      "alpha",
      "3",
      "1.5",
      "true",
      "{\"unsupported\":\"bigint\",\"value\":\"9\"}",
      "widgets",
      "widgets:alpha",
      "2024-01-02T03:04:05.000Z",
      "018cc251-4f5c-7def-b4c6-000000000001",
      "12.34",
      "1h30m",
      "bucket:/key/path",
      "widgets:beta",
      "<future> time::now()",
      "a..z",
      "value: a",
      "widgets:a..z",
      "{\"type\":\"Point\",\"coordinates\":[1,2]}",
      "2024-01-02T03:04:05.000Z",
      "{\"ok\":true}",
      "x, 2",
      "{\"left\":\"x\"}",
      5,
      Some("widgets:alpha"),
      0,
    ))
  })

  Vitest.test("future, cbor codec, and value codec boundaries keep explicit runtime contracts", t => {
    let future = Surrealdb_Future.make("time::now()")
    let codec = Surrealdb_CborCodec.make(~useNativeDates=true, ())
    let valueCodec = Surrealdb_ValueCodec.fromCborCodec(codec)
    let payload =
      Dict.fromArray([
        ("count", Surrealdb_JsValue.int(7)),
        ("label", Surrealdb_JsValue.string("alpha")),
      ])
    let bytes = valueCodec->Surrealdb_ValueCodec.encode(payload->toUnknown)
    let decodeRaw = valueCodec->Surrealdb_ValueCodec.decodeUnknown(bytes)
    let decodeChecked =
      valueCodec->Surrealdb_ValueCodec.decodeWith(bytes, raw =>
        switch raw->Surrealdb_Value.fromUnknown {
        | Object(entries) => Some(entries)
        | _ => None
        }
      )
    let reject =
      valueCodec->Surrealdb_ValueCodec.decodeWith(bytes, _raw =>
        None
      )

    t->Vitest.expect((
      future->Surrealdb_Future.body,
      future->Surrealdb_Future.toString,
      future->Surrealdb_Future.toJSON,
      future->toUnknown->Surrealdb_Future.fromUnknown->Option.isSome,
      future->toUnknown->Surrealdb_Value.fromUnknown->Surrealdb_Value.toText,
      codec->Surrealdb_CborCodec.encode(payload->toUnknown)->Surrealdb_ValueCodec.encodedLength > 0,
      decodeRaw->Surrealdb_Value.fromUnknown->Surrealdb_Value.toText,
      switch decodeChecked {
      | Ok(entries) => entries->Dict.get("label")->Option.map(Surrealdb_Value.toText)
      | Error(_) => None
      },
      switch reject {
      | Error(Surrealdb_ValueCodec.RejectedValue(_)) => true
      | Ok(_) => false
      },
      Surrealdb_ValueCodec.cborFactory(Surrealdb_CborCodec.makeOptions(~useNativeDates=true, ()))
      ->Surrealdb_ValueCodec.encode(payload->toUnknown)
      ->Surrealdb_ValueCodec.encodedLength
      > 0,
    ))->Vitest.Expect.toEqual((
      "time::now()",
      "<future> time::now()",
      "<future> time::now()",
      true,
      "<future> time::now()",
      true,
      "count: 7; label: alpha",
      Some("alpha"),
      true,
      true,
    ))
  })

  Vitest.test("value classification keeps unsupported leaves open instead of widening them away", t => {
    let noneValue = Nullable.undefined->nullableToUnknown->Surrealdb_Value.fromUnknown
    let nullValue = Nullable.null->nullableToUnknown->Surrealdb_Value.fromUnknown
    let bigintValue = 9n->toUnknown
    let symbolValue = symbolForUnknown(~name="demo")
    let arrayValue = [intToUnknown(1), stringToUnknown("two")]->toUnknown->Surrealdb_Value.fromUnknown
    let objectValue =
      Dict.fromArray([
        ("count", intToUnknown(3)),
        ("label", stringToUnknown("x")),
      ])->dictToUnknown->Surrealdb_Value.fromUnknown
    let stringRecordIdValue =
      Surrealdb_StringRecordId.fromString("widgets:alpha")->toUnknown->Surrealdb_Value.fromUnknown
    let recordIdRangeValue =
      Surrealdb_RecordIdRange.make(
        ~table="widgets",
        ~begin=Surrealdb_RangeBound.included(Surrealdb_RangeBound.String("a")),
        ~end=Surrealdb_RangeBound.excluded(Surrealdb_RangeBound.String("z")),
        (),
      )->toUnknown->Surrealdb_Value.fromUnknown
    let rangeValue =
      Surrealdb_Range.make(
        ~begin=Surrealdb_RangeBound.included(Surrealdb_RangeBound.String("a")),
        ~end=Surrealdb_RangeBound.excluded(Surrealdb_RangeBound.String("z")),
        (),
      )->toUnknown->Surrealdb_Value.fromUnknown
    let geometryValue =
      Surrealdb_GeometryPoint.make(
        ~longitude=Surrealdb_GeometryPoint.Float(1.0),
        ~latitude=Surrealdb_GeometryPoint.Float(2.0),
      )->Surrealdb_GeometryPoint.asGeometry->toUnknown->Surrealdb_Value.fromUnknown

    t->Vitest.expect((
      switch noneValue {
      | None => true
      | _ => false
      },
      switch nullValue {
      | Null => true
      | _ => false
      },
      switch bigintValue->Surrealdb_Value.fromUnknown {
      | Unsupported(BigIntValue(value)) => value == 9n
      | _ => false
      },
      switch symbolValue->Surrealdb_Value.fromUnknown {
      | Unsupported(SymbolValue) => true
      | _ => false
      },
      arrayValue->Surrealdb_Value.toText,
      jsonText(~value=objectValue->Surrealdb_Value.toJSON),
      stringRecordIdValue->Surrealdb_Value.toText,
      recordIdRangeValue->Surrealdb_Value.toText,
      rangeValue->Surrealdb_Value.toText,
      jsonText(~value=geometryValue->Surrealdb_Value.toJSON),
    ))->Vitest.Expect.toEqual((
      true,
      true,
      true,
      true,
      "1, two",
      "{\"count\":3,\"label\":\"x\"}",
      "widgets:alpha",
      "widgets:a..z",
      "a..z",
      "{\"type\":\"Point\",\"coordinates\":[1,2]}",
    ))
  })
})
