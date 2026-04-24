let toUnknown = SurrealdbTestCasts.toUnknown
let intToUnknown = SurrealdbTestCasts.intToUnknown

Vitest.describe("SurrealDB public surface", () => {
  Vitest.test("escape, mergeBindings, equals, and jsonify match the SDK runtime functions", t => {
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

    t->Vitest.expect((
      Surrealdb_Escape.ident("foo-bar"),
      Surrealdb_Escape.int(12),
      Surrealdb_Escape.idPart(Surrealdb_JsValue.string("alpha beta")),
      Surrealdb_RangeBound.included(Surrealdb_RangeBound.Int(7))->Surrealdb_Escape.rangeBound,
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
    ))->Vitest.Expect.toEqual((
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

  Vitest.test("jsonify returns parseable JSON for nested SDK values", t => {
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

    t->Vitest.expect((
      jsonText,
      jsonText->JSON.parseOrThrow->JSON.stringifyAny->Option.getOr(""),
    ))->Vitest.Expect.toEqual((
      "{\"when\":\"2026-04-20T00:00:00.000Z\",\"id\":\"widgets:alpha\",\"items\":[1,\"widgets:beta\"],\"meta\":{\"ok\":true,\"label\":\"ready\"}}",
      "{\"when\":\"2026-04-20T00:00:00.000Z\",\"id\":\"widgets:alpha\",\"items\":[1,\"widgets:beta\"],\"meta\":{\"ok\":true,\"label\":\"ready\"}}",
    ))
  })

  Vitest.test("tagged-template exports return the SDK literal types and BoundQuery shape", t => {
    let when_ = Surrealdb_DateTime.fromString("2026-04-20T00:00:00.000Z")
    let query = Surrealdb_Surql.query(
      ["SELECT * FROM ", " WHERE count >= ", ""],
      [Surrealdb_Table.make("widgets")->Surrealdb_JsValue.table, Surrealdb_JsValue.int(3)],
    )

    t->Vitest.expect((
      Surrealdb_Surql.text(["SELECT * FROM ", ""], [Surrealdb_Table.make("widgets")->Surrealdb_JsValue.table]),
      Surrealdb_Surql.dateTime(["2026-04-20T00:00:00.000Z"], [])->Surrealdb_DateTime.toISOString,
      Surrealdb_Surql.recordId(["widgets:alpha"], [])->Surrealdb_StringRecordId.toString,
      Surrealdb_Surql.uuid(["550e8400-e29b-41d4-a716-446655440000"], [])->Surrealdb_Uuid.toString,
      Surrealdb_Surql.toSurrealqlString(when_->Surrealdb_JsValue.dateTime),
      query->Surrealdb_BoundQuery.query,
      query->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length,
    ))->Vitest.Expect.toEqual((
      "SELECT * FROM widgets",
      "2026-04-20T00:00:00.000Z",
      "widgets:alpha",
      "550e8400-e29b-41d4-a716-446655440000",
      "d\"2026-04-20T00:00:00.000Z\"",
      "SELECT * FROM $bind__1 WHERE count >= $bind__2",
      2,
    ))
  })

  Vitest.test("bound query constructors and append overloads match the installed runtime", t => {
    let original = Surrealdb_BoundQuery.fromQuery("RETURN $x", Dict.fromArray([("x", Surrealdb_JsValue.int(1))]))
    let clone = original->Surrealdb_BoundQuery.clone
    let appended = clone->Surrealdb_BoundQuery.appendText("; RETURN 2")
    let templated = appended->Surrealdb_BoundQuery.appendTemplate(["; RETURN ", ""], [Surrealdb_JsValue.int(3)])
    let bare = Surrealdb_BoundQuery.fromText("RETURN 4")

    t->Vitest.expect((
      original->Surrealdb_BoundQuery.query,
      original->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length,
      String.startsWith(templated->Surrealdb_BoundQuery.query, "RETURN $x; RETURN 2; RETURN $bind__"),
      templated->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length,
      bare->Surrealdb_BoundQuery.query,
      bare->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length,
    ))->Vitest.Expect.toEqual((
      "RETURN $x",
      1,
      true,
      2,
      "RETURN 4",
      0,
    ))
  })

  Vitest.test("frame classifier stays open at unknown", t => {
    let randomPayload: dict<unknown> = Dict.make()
    randomPayload->Dict.set("query", intToUnknown(0))

    t->Vitest.expect((
      randomPayload->toUnknown->Surrealdb_Frame.fromUnknown->Option.isSome,
      intToUnknown(7)->Surrealdb_Frame.fromUnknown->Option.isSome,
      randomPayload->toUnknown->Surrealdb_QueryFrame.fromUnknown->Option.isSome,
    ))->Vitest.Expect.toEqual((false, false, false))
  })

  Vitest.test("remote-engine driver options construct a client through the public constructor surface", t => {
    let engines = Surrealdb_RemoteEngines.create()
    let db =
      Surrealdb_Surreal.withOptions(
        ~engines,
        ~codecs=Dict.fromArray([("cbor", Surrealdb_ValueCodec.cborFactory)]),
        ~codecOptions=Surrealdb_CborCodec.makeOptions(~useNativeDates=true, ()),
        ~fetchImpl=Surrealdb_Surreal.defaultFetchImpl,
        (),
      )
    t->Vitest.expect((
      engines->Surrealdb_RemoteEngines.keys,
      db->Surrealdb_Surreal.status,
      db->Surrealdb_Surreal.isConnected,
    ))->Vitest.Expect.toEqual(([
      "ws",
      "wss",
      "http",
      "https",
    ], Surrealdb_ConnectionStatus.Disconnected, false))
  })

  Vitest.test("default websocket impl stays optional at the public boundary", t => {
    t->Vitest.expect(Surrealdb_Surreal.defaultWebSocketImpl->Option.isSome)->Vitest.Expect.toEqual(true)
  })

  Vitest.test("exported Features constants expose the SDK feature values", t => {
    let emptyPayload: dict<unknown> = Dict.make()
    t->Vitest.expect((
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
    ))->Vitest.Expect.toEqual((
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

  Vitest.test("value base class and live action constants match the installed runtime exports", t => {
    let when_ = Surrealdb_DateTime.fromString("2026-04-20T00:00:00.000Z")
    let actionNames = Surrealdb_LiveActions.values()->Array.map(Surrealdb_LiveActions.toString)
    let valueClass = when_->toUnknown->Surrealdb_ValueClass.fromUnknown

    t->Vitest.expect((
      actionNames,
      valueClass->Option.isSome,
      valueClass->Option.map(value => value->Surrealdb_ValueClass.toString),
      valueClass->Option.map(value => value->Surrealdb_ValueClass.equals(when_->toUnknown)),
      valueClass
      ->Option.map(value => value->Surrealdb_ValueClass.toJSON->Surrealdb_Value.fromUnknown->Surrealdb_Value.toText),
    ))->Vitest.Expect.toEqual((
      ["CREATE", "UPDATE", "DELETE", "KILLED"],
      true,
      Some("2026-04-20T00:00:00.000Z"),
      Some(true),
      Some("2026-04-20T00:00:00.000Z"),
    ))
  })

  Vitest.test("expression builders include knn on the installed public SDK surface", t => {
    let vector = [Surrealdb_JsValue.float(1.0), Surrealdb_JsValue.float(2.0), Surrealdb_JsValue.float(3.0)]->Surrealdb_JsValue.array
    let plain = Surrealdb_Expr.knn("embedding", vector, 10)->Surrealdb_Expr.toBoundQuery
    let metric = Surrealdb_Expr.knnWithMetric("embedding", vector, 10, "COSINE")->Surrealdb_Expr.toBoundQuery
    let ef = Surrealdb_Expr.knnWithEf("embedding", vector, 10, 50)->Surrealdb_Expr.toBoundQuery

    t->Vitest.expect((
      String.startsWith(plain->Surrealdb_BoundQuery.query, "embedding <|10|> $bind__"),
      plain->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length,
      String.startsWith(metric->Surrealdb_BoundQuery.query, "embedding <|10,COSINE|> $bind__"),
      String.startsWith(ef->Surrealdb_BoundQuery.query, "embedding <|10,50|> $bind__"),
    ))->Vitest.Expect.toEqual((
      true,
      1,
      true,
      true,
    ))
  })

  Vitest.test("value classes expose the broader public SDK method surface", t => {
    let duration = Surrealdb_Duration.fromString("2h")
    let ninetyMinutes = Surrealdb_Duration.fromString("90m")
    let start = Surrealdb_DateTime.fromString("2026-04-20T00:00:00.000Z")
    let decimal = Surrealdb_Decimal.fromString("12.3456")
    let uuid = Surrealdb_Uuid.v4()

    t->Vitest.expect((
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
    ))->Vitest.Expect.toEqual((
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

  Vitest.test("record id and decimal constructors cover wider public value shapes", t => {
    let uuid = Surrealdb_Uuid.fromString("550e8400-e29b-41d4-a716-446655440000")
    let stringRecordId =
      Surrealdb_RecordId.make("widgets", "alpha")->Surrealdb_StringRecordId.fromRecordId

    t->Vitest.expect((
      Surrealdb_RecordId.makeWithUuidId("widgets", uuid)->Surrealdb_RecordId.toString,
      Surrealdb_RecordId.makeWithIdValue(
        "widgets",
        Surrealdb_RecordId.ArrayId([Surrealdb_RecordId.String("alpha"), Surrealdb_RecordId.Int(2)]),
      )->Surrealdb_RecordId.toString,
      Surrealdb_RecordId.makeFromTableWithIdValue(
        Surrealdb_Table.make("widgets"),
        Surrealdb_RecordId.ObjectId(Dict.fromArray([("slug", Surrealdb_RecordId.String("alpha"))])),
      )->Surrealdb_RecordId.toString,
      Surrealdb_RecordId.makeWithNumberId("widgets", 2.5)->Surrealdb_RecordId.idValue,
      stringRecordId->Surrealdb_StringRecordId.fromStringRecordId->Surrealdb_StringRecordId.toString,
      Surrealdb_Decimal.fromScientificNotation("1.23e4")->Surrealdb_Decimal.toString,
    ))->Vitest.Expect.toEqual((
      "widgets:u\"550e8400-e29b-41d4-a716-446655440000\"",
      "widgets:[ s\"alpha\", 2 ]",
      "widgets:{ \"slug\": s\"alpha\" }",
      Some(Surrealdb_RecordId.NumberId(2.5)),
      "widgets:alpha",
      "12300",
    ))
  })

  Vitest.test("json-mode builder surfaces keep JSON-specific result types across the public modules", t => {
    let db = Surrealdb_Surreal.make()
    let queryable = db->Surrealdb_Surreal.asQueryable
    let payload = Dict.fromArray([("label", Surrealdb_JsValue.string("alpha"))])->Surrealdb_JsValue.object
    let edgeTable = Surrealdb_Table.make("rel")
    let fromRecord = Surrealdb_RecordId.make("widgets", "a")
    let toRecord = Surrealdb_RecordId.make("widgets", "b")
    let _queryJsonBuilder: Surrealdb_Query.t<array<JSON.t>> =
      queryable->Surrealdb_Query.textOn("RETURN 1;", ())->Surrealdb_Query.json
    let _queryResolveJson: Surrealdb_Query.t<array<JSON.t>> => promise<array<JSON.t>> = Surrealdb_Query.resolveJson
    let _queryStreamJson: Surrealdb_Query.t<array<JSON.t>> => Surrealdb_AsyncIterable.t<Surrealdb_JsonFrame.t> = Surrealdb_Query.streamJson
    let _selectJsonBuilder: Surrealdb_Select.t<JSON.t> =
      queryable->Surrealdb_Select.tableOn("widgets")->Surrealdb_Select.json
    let _selectResolveJson: Surrealdb_Select.t<JSON.t> => promise<JSON.t> = Surrealdb_Select.resolveJson
    let _selectStreamJson: Surrealdb_Select.t<JSON.t> => Surrealdb_AsyncIterable.t<Surrealdb_JsonFrame.t> = Surrealdb_Select.streamJson
    let _createJsonBuilder: Surrealdb_Create.t<JSON.t> =
      queryable->Surrealdb_Create.tableOn("widgets")->Surrealdb_Create.json
    let _createResolveJson: Surrealdb_Create.t<JSON.t> => promise<JSON.t> = Surrealdb_Create.resolveJson
    let _updateJsonBuilder: Surrealdb_Update.t<JSON.t> =
      queryable->Surrealdb_Update.tableOn("widgets")->Surrealdb_Update.json
    let _updateResolveJson: Surrealdb_Update.t<JSON.t> => promise<JSON.t> = Surrealdb_Update.resolveJson
    let _upsertJsonBuilder: Surrealdb_Upsert.t<JSON.t> =
      queryable->Surrealdb_Upsert.tableOn("widgets")->Surrealdb_Upsert.json
    let _upsertResolveJson: Surrealdb_Upsert.t<JSON.t> => promise<JSON.t> = Surrealdb_Upsert.resolveJson
    let _deleteJsonBuilder: Surrealdb_Delete.t<JSON.t> =
      queryable->Surrealdb_Delete.tableOn("widgets")->Surrealdb_Delete.json
    let _deleteResolveJson: Surrealdb_Delete.t<JSON.t> => promise<JSON.t> = Surrealdb_Delete.resolveJson
    let _insertJsonBuilder: Surrealdb_Insert.t<JSON.t> =
      queryable->Surrealdb_Insert.tableOn("widgets", payload)->Surrealdb_Insert.json
    let _insertResolveJson: Surrealdb_Insert.t<JSON.t> => promise<JSON.t> = Surrealdb_Insert.resolveJson
    let _relateJsonBuilder: Surrealdb_Relate.t<JSON.t> =
      queryable->Surrealdb_Relate.recordsOn(fromRecord, edgeTable, toRecord, ())->Surrealdb_Relate.json
    let _relateResolveJson: Surrealdb_Relate.t<JSON.t> => promise<JSON.t> = Surrealdb_Relate.resolveJson
    let _runJsonBuilder: Surrealdb_Run.t<JSON.t> =
      queryable
      ->Surrealdb_Run.callOn("string::len", ~args=[Surrealdb_JsValue.string("alpha")], ())
      ->Surrealdb_Run.json
    let _runResolveJson: Surrealdb_Run.t<JSON.t> => promise<JSON.t> = Surrealdb_Run.resolveJson
    let _authJsonBuilder: Surrealdb_Auth.t<JSON.t> =
      queryable->Surrealdb_Queryable.auth->Surrealdb_Auth.json
    let _authResolveJson: Surrealdb_Auth.t<JSON.t> => promise<JSON.t> = Surrealdb_Auth.resolveJson
    let _authStreamJson: Surrealdb_Auth.t<JSON.t> => Surrealdb_AsyncIterable.t<Surrealdb_JsonFrame.t> = Surrealdb_Auth.streamJson
    let _apiJson:
      Surrealdb_ApiPromise.t<Surrealdb_ApiPromise.responseMode, Surrealdb_ApiPromise.valueFormat> => Surrealdb_ApiPromise.t<Surrealdb_ApiPromise.responseMode, Surrealdb_ApiPromise.jsonFormat> =
      Surrealdb_ApiPromise.json
    let _apiResolveJson:
      Surrealdb_ApiPromise.t<Surrealdb_ApiPromise.responseMode, Surrealdb_ApiPromise.jsonFormat> => promise<Surrealdb_ApiJsonResponse.t> =
      Surrealdb_ApiPromise.resolveJson
    let _apiStreamJson:
      Surrealdb_ApiPromise.t<Surrealdb_ApiPromise.responseMode, Surrealdb_ApiPromise.jsonFormat> => Surrealdb_AsyncIterable.t<Surrealdb_Frame.t<Surrealdb_ApiJsonResponse.t>> =
      Surrealdb_ApiPromise.streamJson
    let _apiValue:
      Surrealdb_ApiPromise.t<Surrealdb_ApiPromise.responseMode, Surrealdb_ApiPromise.jsonFormat> => Surrealdb_ApiPromise.t<Surrealdb_ApiPromise.bodyMode, Surrealdb_ApiPromise.jsonFormat> =
      Surrealdb_ApiPromise.value
    let _apiAwaitValueJson:
      Surrealdb_ApiPromise.t<Surrealdb_ApiPromise.bodyMode, Surrealdb_ApiPromise.jsonFormat> => promise<JSON.t> =
      Surrealdb_ApiPromise.awaitValueJson

    t->Vitest.expect((
      queryable->Surrealdb_Query.textOn("RETURN 1;", ())->Surrealdb_Query.json->Surrealdb_Query.inner->Surrealdb_BoundQuery.query,
      queryable
      ->Surrealdb_Select.tableOn("widgets")
      ->Surrealdb_Select.json
      ->Surrealdb_Select.compile
      ->Surrealdb_BoundQuery.query
      ->String.startsWith("SELECT * FROM $bind__"),
      queryable
      ->Surrealdb_Create.tableOn("widgets")
      ->Surrealdb_Create.json
      ->Surrealdb_Create.compile
      ->Surrealdb_BoundQuery.query
      ->String.startsWith("CREATE $bind__"),
      queryable
      ->Surrealdb_Update.tableOn("widgets")
      ->Surrealdb_Update.json
      ->Surrealdb_Update.compile
      ->Surrealdb_BoundQuery.query
      ->String.startsWith("UPDATE $bind__"),
      queryable
      ->Surrealdb_Upsert.tableOn("widgets")
      ->Surrealdb_Upsert.json
      ->Surrealdb_Upsert.compile
      ->Surrealdb_BoundQuery.query
      ->String.startsWith("UPSERT $bind__"),
      queryable
      ->Surrealdb_Delete.tableOn("widgets")
      ->Surrealdb_Delete.json
      ->Surrealdb_Delete.compile
      ->Surrealdb_BoundQuery.query
      ->String.includes("RETURN BEFORE"),
      queryable
      ->Surrealdb_Delete.tableOn("widgets")
      ->Surrealdb_Delete.json
      ->Surrealdb_Delete.compile
      ->Surrealdb_BoundQuery.query
      ->String.startsWith("DELETE $bind__"),
      queryable
      ->Surrealdb_Insert.tableOn("widgets", payload)
      ->Surrealdb_Insert.json
      ->Surrealdb_Insert.compile
      ->Surrealdb_BoundQuery.query
      ->String.startsWith("INSERT INTO $bind__"),
      queryable
      ->Surrealdb_Relate.recordsOn(fromRecord, edgeTable, toRecord, ())
      ->Surrealdb_Relate.json
      ->Surrealdb_Relate.compile
      ->Surrealdb_BoundQuery.query
      ->String.startsWith("RELATE  ONLY $bind__"),
      queryable
      ->Surrealdb_Run.callOn("string::len", ~args=[Surrealdb_JsValue.string("alpha")], ())
      ->Surrealdb_Run.json
      ->Surrealdb_Run.compile
      ->Surrealdb_BoundQuery.query
      ->String.startsWith("string::len("),
      queryable->Surrealdb_Queryable.auth->Surrealdb_Auth.json->Surrealdb_Auth.compile->Surrealdb_BoundQuery.query,
    ))->Vitest.Expect.toEqual((
      "RETURN 1;",
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      "SELECT * FROM ONLY $auth",
    ))
  })

  Vitest.test("geometry and range value surfaces match the installed public SDK", t => {
    let firstPoint = Surrealdb_GeometryPoint.make(~longitude=Float(1.0), ~latitude=Float(2.0))
    let secondPoint = Surrealdb_GeometryPoint.make(~longitude=Float(3.0), ~latitude=Float(4.0))
    let line = Surrealdb_GeometryLine.make(~first=firstPoint, ~second=secondPoint)
    let polygon = Surrealdb_GeometryPolygon.make(~outerBoundary=line)
    let range =
      Surrealdb_Range.make(
        ~begin=Surrealdb_RangeBound.included(Surrealdb_RangeBound.Int(1)),
        ~end=Surrealdb_RangeBound.excluded(Surrealdb_RangeBound.Int(5)),
        (),
      )
    let recordIdRange =
      Surrealdb_RecordIdRange.make(
        ~table="widgets",
        ~begin=Surrealdb_RangeBound.included(Surrealdb_RangeBound.String("a")),
        ~end=Surrealdb_RangeBound.excluded(Surrealdb_RangeBound.String("z")),
        (),
      )

    t->Vitest.expect((
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
    ))->Vitest.Expect.toEqual((
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

  Vitest.test("value codec interface round-trips through the public SDK surface", t => {
    let codec = Surrealdb_CborCodec.default()->Surrealdb_ValueCodec.fromCborCodec
    let encoded = codec->Surrealdb_ValueCodec.encode("alpha"->toUnknown)
    let decoded =
      codec->Surrealdb_ValueCodec.decodeWith(encoded, raw =>
        switch raw->Surrealdb_Value.fromUnknown {
        | String(value) => Some(value)
        | _ => None
        }
      )

    t->Vitest.expect((
      encoded->Surrealdb_ValueCodec.encodedLength > 0,
      switch decoded {
      | Ok(value) => value
      | Error(_) => "<decode-error>"
      },
    ))->Vitest.Expect.toEqual((
      true,
      "alpha",
    ))
  })

  Vitest.test("remote engine factories instantiate the exported transport classes", t => {
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

    t->Vitest.expect((
      wsEngine->Surrealdb_RpcEngine.fromEngine->Option.isSome,
      wsEngine->Surrealdb_WebSocketEngine.fromEngine->Option.isSome,
      wsEngine->Surrealdb_HttpEngine.fromEngine->Option.isSome,
      wsEngine->Surrealdb_Engine.features->Array.map(Surrealdb_Feature.name),
      httpEngine->Surrealdb_RpcEngine.fromEngine->Option.isSome,
      httpEngine->Surrealdb_HttpEngine.fromEngine->Option.isSome,
      httpEngine->Surrealdb_WebSocketEngine.fromEngine->Option.isSome,
      httpEngine->Surrealdb_Engine.features->Array.map(Surrealdb_Feature.name),
    ))->Vitest.Expect.toEqual((
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

  Vitest.test("record-id-range overloads compile through the public queryable surface", t => {
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

    t->Vitest.expect((
      String.startsWith(selectCompiled->Surrealdb_BoundQuery.query, "SELECT * FROM $bind__"),
      String.startsWith(updateCompiled->Surrealdb_BoundQuery.query, "UPDATE $bind__"),
      String.startsWith(upsertCompiled->Surrealdb_BoundQuery.query, "UPSERT $bind__"),
      String.startsWith(deleteCompiled->Surrealdb_BoundQuery.query, "DELETE $bind__"),
      selectBinding,
    ))->Vitest.Expect.toEqual((
      true,
      true,
      true,
      true,
      Some("widgets:.."),
    ))
  })
})
