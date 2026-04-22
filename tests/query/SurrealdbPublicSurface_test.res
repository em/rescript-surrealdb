open TestRuntime

external toUnknown: 'a => unknown = "%identity"
external intToUnknown: int => unknown = "%identity"

describe("SurrealDB public surface", () => {
  test("escape, mergeBindings, equals, and jsonify match the SDK runtime functions", () => {
    let when_ = Surrealdb_DateTime.fromString("2026-04-20T00:00:00.000Z")
    let recordId = Surrealdb_RecordId.make("widgets", "alpha")
    let target = Dict.fromArray([("left", Surrealdb_JsValue.string("alpha"))])
    let source = Dict.fromArray([("right", Surrealdb_JsValue.recordId(recordId))])
    target->Surrealdb_BoundQuery.mergeBindings(source)

    let payload =
      Dict.fromArray([
        ("when", when_->Surrealdb_JsValue.dateTime),
        ("id", recordId->Surrealdb_JsValue.recordId),
      ])

    (
      Surrealdb_Escape.ident("foo-bar"),
      Surrealdb_Escape.int(12),
      Surrealdb_Escape.idPart(Surrealdb_JsValue.string("alpha beta")),
      Surrealdb_RangeBound.included(intToUnknown(7))->Surrealdb_Escape.rangeBound,
      when_->Surrealdb_JsValue.dateTime->Surrealdb_Surql.toString,
      Surrealdb_Equals.values(
        recordId->Surrealdb_JsValue.recordId,
        Surrealdb_RecordId.make("widgets", "alpha")->Surrealdb_JsValue.recordId,
      ),
      target->Dict.get("right")->Option.isSome,
      payload
      ->Surrealdb_JsValue.object
      ->Surrealdb_Jsonify.value
      ->JSON.stringifyAny
      ->Option.getOr(""),
    )
    ->Expect.expect
    ->Expect.toEqual((
      "⟨foo-bar⟩",
      "12",
      "⟨alpha beta⟩",
      "7",
      "d\"2026-04-20T00:00:00.000Z\"",
      true,
      true,
      "{\"when\":\"2026-04-20T00:00:00.000Z\",\"id\":\"widgets:alpha\"}",
    ))
  })

  test("jsonify returns parseable JSON for nested SDK values", () => {
    let when_ = Surrealdb_DateTime.fromString("2026-04-20T00:00:00.000Z")
    let payload =
      Dict.fromArray([
        ("when", when_->Surrealdb_JsValue.dateTime),
        ("id", Surrealdb_RecordId.make("widgets", "alpha")->Surrealdb_JsValue.recordId),
        (
          "items",
          [
            Surrealdb_JsValue.int(1),
            Surrealdb_RecordId.make("widgets", "beta")->Surrealdb_JsValue.recordId,
          ]->Surrealdb_JsValue.array,
        ),
        (
          "meta",
          Dict.fromArray([
            ("ok", Surrealdb_JsValue.bool(true)),
            ("label", Surrealdb_JsValue.string("ready")),
          ])->Surrealdb_JsValue.object,
        ),
      ])
    let jsonText =
      payload
      ->Surrealdb_JsValue.object
      ->Surrealdb_Jsonify.value
      ->JSON.stringifyAny
      ->Option.getOr("")

    (
      jsonText,
      jsonText->JSON.parseOrThrow->JSON.stringifyAny->Option.getOr(""),
    )
    ->Expect.expect
    ->Expect.toEqual((
      "{\"when\":\"2026-04-20T00:00:00.000Z\",\"id\":\"widgets:alpha\",\"items\":[1,\"widgets:beta\"],\"meta\":{\"ok\":true,\"label\":\"ready\"}}",
      "{\"when\":\"2026-04-20T00:00:00.000Z\",\"id\":\"widgets:alpha\",\"items\":[1,\"widgets:beta\"],\"meta\":{\"ok\":true,\"label\":\"ready\"}}",
    ))
  })

  test("tagged-template exports return the SDK literal types and BoundQuery shape", () => {
    let when_ = Surrealdb_DateTime.fromString("2026-04-20T00:00:00.000Z")
    let query = Surrealdb_Surql.query(
      ["SELECT * FROM ", " WHERE count >= ", ""],
      [Surrealdb_Table.make("widgets")->Surrealdb_JsValue.table, Surrealdb_JsValue.int(3)],
    )

    (
      Surrealdb_Surql.text(["SELECT * FROM ", ""], [Surrealdb_Table.make("widgets")->Surrealdb_JsValue.table]),
      Surrealdb_Surql.dateTime(["2026-04-20T00:00:00.000Z"], [])->Surrealdb_DateTime.toISOString,
      Surrealdb_Surql.recordId(["widgets:alpha"], [])->Surrealdb_StringRecordId.toString,
      Surrealdb_Surql.uuid(["550e8400-e29b-41d4-a716-446655440000"], [])->Surrealdb_Uuid.toString,
      Surrealdb_Surql.toSurrealqlString(when_->Surrealdb_JsValue.dateTime),
      query->Surrealdb_BoundQuery.query,
      query->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length,
    )
    ->Expect.expect
    ->Expect.toEqual((
      "SELECT * FROM widgets",
      "2026-04-20T00:00:00.000Z",
      "widgets:alpha",
      "550e8400-e29b-41d4-a716-446655440000",
      "d\"2026-04-20T00:00:00.000Z\"",
      "SELECT * FROM $bind__1 WHERE count >= $bind__2",
      2,
    ))
  })

  test("bound query constructors and append overloads match the installed runtime", () => {
    let original = Surrealdb_BoundQuery.fromQuery("RETURN $x", Dict.fromArray([("x", Surrealdb_JsValue.int(1))]))
    let clone = original->Surrealdb_BoundQuery.clone
    let appended = clone->Surrealdb_BoundQuery.appendText("; RETURN 2")
    let templated = appended->Surrealdb_BoundQuery.appendTemplate(["; RETURN ", ""], [Surrealdb_JsValue.int(3)])
    let bare = Surrealdb_BoundQuery.fromText("RETURN 4")

    (
      original->Surrealdb_BoundQuery.query,
      original->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length,
      String.startsWith(templated->Surrealdb_BoundQuery.query, "RETURN $x; RETURN 2; RETURN $bind__"),
      templated->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length,
      bare->Surrealdb_BoundQuery.query,
      bare->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length,
    )
    ->Expect.expect
    ->Expect.toEqual((
      "RETURN $x",
      1,
      true,
      2,
      "RETURN 4",
      0,
    ))
  })

  test("frame classifier stays open at unknown", () => {
    let randomPayload: dict<unknown> = Dict.make()
    randomPayload->Dict.set("query", intToUnknown(0))

    (
      randomPayload->toUnknown->Surrealdb_Frame.fromUnknown->Option.isSome,
      intToUnknown(7)->Surrealdb_Frame.fromUnknown->Option.isSome,
      randomPayload->toUnknown->Surrealdb_QueryFrame.fromUnknown->Option.isSome,
    )
    ->Expect.expect
    ->Expect.toEqual((false, false, false))
  })

  test("remote-engine driver options construct a client through the public constructor surface", () => {
    let engines = Surrealdb_RemoteEngines.create()
    let db =
      Surrealdb_Surreal.withOptions(
        ~engines,
        ~codecs=Dict.fromArray([("cbor", Surrealdb_ValueCodec.cborFactory)]),
        ~codecOptions=Surrealdb_CborCodec.makeOptions(~useNativeDates=true, ()),
        ~fetchImpl=Surrealdb_Surreal.defaultFetchImpl,
        (),
      )
    (
      engines->Surrealdb_RemoteEngines.keys,
      db->Surrealdb_Surreal.status,
      db->Surrealdb_Surreal.isConnected,
    )
    ->Expect.expect
    ->Expect.toEqual((["ws", "wss", "http", "https"], "disconnected", false))
  })

  test("default websocket impl stays optional at the public boundary", () => {
    Surrealdb_Surreal.defaultWebSocketImpl->Option.isSome->Expect.expect->Expect.toEqual(true)
  })

  test("exported Features constants expose the SDK feature values", () => {
    let emptyPayload: dict<unknown> = Dict.make()
    (
      Surrealdb_Features.liveQueries->Surrealdb_Feature.name,
      Surrealdb_Features.sessions->Surrealdb_Feature.name,
      Surrealdb_Features.api->Surrealdb_Feature.name,
      Surrealdb_Features.refreshTokens->Surrealdb_Feature.name,
      Surrealdb_Features.transactions->Surrealdb_Feature.name,
      Surrealdb_Features.exportImportRaw->Surrealdb_Feature.name,
      Surrealdb_Features.surrealMl->Surrealdb_Feature.name,
      Surrealdb_Features.fromString("sessions")->Option.map(Surrealdb_Feature.name),
      Surrealdb_Features.fromString("missing")->Option.isSome,
      Surrealdb_Features.liveQueries->toUnknown->Surrealdb_Feature.isInstance,
      emptyPayload->toUnknown->Surrealdb_Feature.isInstance,
      Surrealdb_Features.liveQueries
      ->toUnknown
      ->Surrealdb_Feature.fromUnknown
      ->Option.map(feature => feature->Surrealdb_Feature.toJSON->JSON.stringifyAny->Option.getOr("")),
    )
    ->Expect.expect
    ->Expect.toEqual((
      "live-queries",
      "sessions",
      "api",
      "refresh-tokens",
      "transactions",
      "export-import-raw",
      "surreal-ml",
      Some("sessions"),
      false,
      true,
      false,
      Some("{\"name\":\"live-queries\"}"),
    ))
  })

  test("value base class and live action constants match the installed runtime exports", () => {
    let when_ = Surrealdb_DateTime.fromString("2026-04-20T00:00:00.000Z")
    let actionNames = Surrealdb_LiveActions.values()->Array.map(Surrealdb_LiveActions.toString)
    let valueClass = when_->toUnknown->Surrealdb_ValueClass.fromUnknown

    (
      actionNames,
      valueClass->Option.isSome,
      valueClass->Option.map(value => value->Surrealdb_ValueClass.toString),
      valueClass->Option.map(value => value->Surrealdb_ValueClass.equals(when_->toUnknown)),
      valueClass
      ->Option.map(value => value->Surrealdb_ValueClass.toJSON->Surrealdb_Value.fromUnknown->Surrealdb_Value.toText),
    )
    ->Expect.expect
    ->Expect.toEqual((
      ["CREATE", "UPDATE", "DELETE", "KILLED"],
      true,
      Some("2026-04-20T00:00:00.000Z"),
      Some(true),
      Some("2026-04-20T00:00:00.000Z"),
    ))
  })

  test("expression builders include knn on the installed public SDK surface", () => {
    let vector = [Surrealdb_JsValue.float(1.0), Surrealdb_JsValue.float(2.0), Surrealdb_JsValue.float(3.0)]->Surrealdb_JsValue.array
    let plain = Surrealdb_Expr.knn("embedding", vector, 10)->Surrealdb_Expr.toBoundQuery
    let metric = Surrealdb_Expr.knnWithMetric("embedding", vector, 10, "COSINE")->Surrealdb_Expr.toBoundQuery
    let ef = Surrealdb_Expr.knnWithEf("embedding", vector, 10, 50)->Surrealdb_Expr.toBoundQuery

    (
      String.startsWith(plain->Surrealdb_BoundQuery.query, "embedding <|10|> $bind__"),
      plain->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length,
      String.startsWith(metric->Surrealdb_BoundQuery.query, "embedding <|10,COSINE|> $bind__"),
      String.startsWith(ef->Surrealdb_BoundQuery.query, "embedding <|10,50|> $bind__"),
    )
    ->Expect.expect
    ->Expect.toEqual((
      true,
      1,
      true,
      true,
    ))
  })

  test("value classes expose the broader public SDK method surface", () => {
    let duration = Surrealdb_Duration.fromString("2h")
    let ninetyMinutes = Surrealdb_Duration.fromString("90m")
    let start = Surrealdb_DateTime.fromString("2026-04-20T00:00:00.000Z")
    let decimal = Surrealdb_Decimal.fromString("12.3456")
    let uuid = Surrealdb_Uuid.v4()

    (
      duration->Surrealdb_Duration.sub(Surrealdb_Duration.fromString("30m"))->Surrealdb_Duration.toString,
      duration->Surrealdb_Duration.mulByInt(2)->Surrealdb_Duration.toString,
      duration->Surrealdb_Duration.divByInt(2)->Surrealdb_Duration.toString,
      duration->Surrealdb_Duration.mod(ninetyMinutes)->Surrealdb_Duration.toString,
      start->Surrealdb_DateTime.add(ninetyMinutes)->Surrealdb_DateTime.toISOString,
      start->Surrealdb_DateTime.add(ninetyMinutes)->Surrealdb_DateTime.diff(start)->Surrealdb_Duration.toString,
      decimal->Surrealdb_Decimal.round(2)->Surrealdb_Decimal.toString,
      decimal->Surrealdb_Decimal.toFixed(2),
      decimal->Surrealdb_Decimal.toScientific,
      decimal->Surrealdb_Decimal.neg->Surrealdb_Decimal.isNegative,
      decimal->Surrealdb_Decimal.abs->Surrealdb_Decimal.toString,
      decimal->Surrealdb_Decimal.compare(Surrealdb_Decimal.fromString("12.3456")),
      uuid->Surrealdb_Uuid.bytesLength,
      uuid->Surrealdb_Uuid.bufferByteLength,
    )
    ->Expect.expect
    ->Expect.toEqual((
      "1h30m",
      "4h",
      "1h",
      "30m",
      "2026-04-20T01:30:00.000Z",
      "1h30m",
      "12.35",
      "12.35",
      "1.23456e1",
      true,
      "12.3456",
      0,
      16,
      16,
    ))
  })

  test("record id and decimal constructors cover wider public value shapes", () => {
    let uuid = Surrealdb_Uuid.fromString("550e8400-e29b-41d4-a716-446655440000")
    let stringRecordId =
      Surrealdb_RecordId.make("widgets", "alpha")->Surrealdb_StringRecordId.fromRecordId

    (
      Surrealdb_RecordId.makeWithUuidId("widgets", uuid)->Surrealdb_RecordId.toString,
      Surrealdb_RecordId.makeWithIdValue(
        "widgets",
        Surrealdb_RecordId.ArrayId([JSON.Encode.string("alpha"), JSON.Encode.int(2)]),
      )->Surrealdb_RecordId.toString,
      Surrealdb_RecordId.makeFromTableWithIdValue(
        Surrealdb_Table.make("widgets"),
        Surrealdb_RecordId.ObjectId(Dict.fromArray([("slug", JSON.Encode.string("alpha"))])),
      )->Surrealdb_RecordId.toString,
      Surrealdb_RecordId.makeWithNumberId("widgets", 2.5)->Surrealdb_RecordId.idValue,
      stringRecordId->Surrealdb_StringRecordId.fromStringRecordId->Surrealdb_StringRecordId.toString,
      Surrealdb_Decimal.fromScientificNotation("1.23e4")->Surrealdb_Decimal.toString,
    )
    ->Expect.expect
    ->Expect.toEqual((
      "widgets:u\"550e8400-e29b-41d4-a716-446655440000\"",
      "widgets:[ s\"alpha\", 2 ]",
      "widgets:{ \"slug\": s\"alpha\" }",
      Surrealdb_RecordId.NumberId(2.5),
      "widgets:alpha",
      "12300",
    ))
  })

  test("geometry and range value surfaces match the installed public SDK", () => {
    let firstPoint = Surrealdb_GeometryPoint.make(~longitude=Float(1.0), ~latitude=Float(2.0))
    let secondPoint = Surrealdb_GeometryPoint.make(~longitude=Float(3.0), ~latitude=Float(4.0))
    let line = Surrealdb_GeometryLine.make(~first=firstPoint, ~second=secondPoint)
    let polygon = Surrealdb_GeometryPolygon.make(~outerBoundary=line)
    let range =
      Surrealdb_Range.make(
        ~begin=Surrealdb_RangeBound.included(intToUnknown(1)),
        ~end=Surrealdb_RangeBound.excluded(intToUnknown(5)),
        (),
      )
    let recordIdRange =
      Surrealdb_RecordIdRange.make(
        ~table="widgets",
        ~begin=Surrealdb_RangeBound.included("a"->toUnknown),
        ~end=Surrealdb_RangeBound.excluded("z"->toUnknown),
        (),
      )

    (
      firstPoint->Surrealdb_GeometryPoint.coordinates,
      line->Surrealdb_GeometryLine.coordinates,
      line->Surrealdb_GeometryLine.matches(line->Surrealdb_GeometryLine.clone->Surrealdb_GeometryLine.asGeometry),
      polygon
      ->Surrealdb_GeometryPolygon.matches(
          polygon->Surrealdb_GeometryPolygon.clone->Surrealdb_GeometryPolygon.asGeometry,
        ),
      range->Surrealdb_Range.toString,
      range
      ->Surrealdb_Range.begin
      ->Option.map(bound => bound->Surrealdb_RangeBound.value->Surrealdb_BoundValue.toText),
      range
      ->Surrealdb_Range.end_
      ->Option.map(bound => bound->Surrealdb_RangeBound.value->Surrealdb_BoundValue.toText),
      recordIdRange->Surrealdb_RecordIdRange.toString,
      recordIdRange
      ->Surrealdb_RecordIdRange.begin
      ->Option.map(bound => bound->Surrealdb_RangeBound.value->Surrealdb_BoundValue.toText),
      recordIdRange
      ->Surrealdb_RecordIdRange.end_
      ->Option.map(bound => bound->Surrealdb_RangeBound.value->Surrealdb_BoundValue.toText),
    )
    ->Expect.expect
    ->Expect.toEqual((
      [1.0, 2.0],
      [[1.0, 2.0], [3.0, 4.0]],
      true,
      true,
      "1..5",
      Some("1"),
      Some("5"),
      "widgets:a..z",
      Some("a"),
      Some("z"),
    ))
  })

  test("value codec interface round-trips through the public SDK surface", () => {
    let codec = Surrealdb_CborCodec.default()->Surrealdb_ValueCodec.fromCborCodec
    let encoded = codec->Surrealdb_ValueCodec.encode("alpha"->toUnknown)
    let decoded =
      codec->Surrealdb_ValueCodec.decodeWith(encoded, raw =>
        switch raw->Surrealdb_Value.fromUnknown {
        | String(value) => Some(value)
        | _ => None
        }
      )

    (
      encoded->Surrealdb_ValueCodec.encodedLength > 0,
      switch decoded {
      | Ok(value) => value
      | Error(_) => "<decode-error>"
      },
    )
    ->Expect.expect
    ->Expect.toEqual((
      true,
      "alpha",
    ))
  })

  test("remote engine factories instantiate the exported transport classes", () => {
    let engines = Surrealdb_RemoteEngines.create()
    let codecFactories = Dict.fromArray([("cbor", Surrealdb_ValueCodec.cborFactory)])
    let codecRegistry =
      Dict.fromArray([("cbor", Surrealdb_CborCodec.default()->Surrealdb_ValueCodec.fromCborCodec)])
    let options =
      Surrealdb_Surreal.driverOptions(
        ~engines,
        ~codecs=codecFactories,
        ~codecOptions=Surrealdb_CborCodec.makeOptions(),
        ~fetchImpl=Surrealdb_Surreal.defaultFetchImpl,
        (),
      )
    let context = Surrealdb_DriverContext.make(~options, ~uniqueId=(() => "engine-test"), ~codecs=codecRegistry)
    let wsEngine = context->Surrealdb_DriverContext.instantiate(engines->Surrealdb_RemoteEngines.ws)
    let httpEngine =
      context->Surrealdb_DriverContext.instantiate(engines->Surrealdb_RemoteEngines.http)

    (
      wsEngine->Surrealdb_RpcEngine.fromEngine->Option.isSome,
      wsEngine->Surrealdb_WebSocketEngine.fromEngine->Option.isSome,
      wsEngine->Surrealdb_HttpEngine.fromEngine->Option.isSome,
      wsEngine->Surrealdb_Engine.features->Array.map(Surrealdb_Feature.name),
      httpEngine->Surrealdb_RpcEngine.fromEngine->Option.isSome,
      httpEngine->Surrealdb_HttpEngine.fromEngine->Option.isSome,
      httpEngine->Surrealdb_WebSocketEngine.fromEngine->Option.isSome,
      httpEngine->Surrealdb_Engine.features->Array.map(Surrealdb_Feature.name),
    )
    ->Expect.expect
    ->Expect.toEqual((
      true,
      true,
      false,
      ["live-queries", "refresh-tokens", "sessions", "transactions", "api", "export-import-raw", "surreal-ml"],
      true,
      true,
      false,
      ["refresh-tokens", "api", "export-import-raw", "surreal-ml"],
    ))
  })

  test("record-id-range overloads compile through the public queryable surface", () => {
    let db = Surrealdb_RemoteEngines.create()->Surrealdb_Surreal.withRemoteEngines
    let range = Surrealdb_RecordIdRange.make(~table="widgets", ())
    let selectCompiled = db->Surrealdb_Select.range(range)->Surrealdb_Select.compile
    let updateCompiled = db->Surrealdb_Update.fromRange(range)->Surrealdb_Update.compile
    let upsertCompiled = db->Surrealdb_Upsert.fromRange(range)->Surrealdb_Upsert.compile
    let deleteCompiled = db->Surrealdb_Delete.fromRange(range)->Surrealdb_Delete.compile
    let selectBinding =
      selectCompiled
      ->Surrealdb_BoundQuery.bindings
      ->Dict.toArray
      ->Array.get(0)
      ->Option.map(((_key, value)) => value->toUnknown->Surrealdb_Value.fromUnknown->Surrealdb_Value.toText)

    (
      String.startsWith(selectCompiled->Surrealdb_BoundQuery.query, "SELECT * FROM $bind__"),
      String.startsWith(updateCompiled->Surrealdb_BoundQuery.query, "UPDATE $bind__"),
      String.startsWith(upsertCompiled->Surrealdb_BoundQuery.query, "UPSERT $bind__"),
      String.startsWith(deleteCompiled->Surrealdb_BoundQuery.query, "DELETE $bind__"),
      selectBinding,
    )
    ->Expect.expect
    ->Expect.toEqual((
      true,
      true,
      true,
      true,
      Some("widgets:.."),
    ))
  })
})
