module Support = SurrealdbCoverageTestSupport

let jsonText = Support.jsonText
let makeRawApiResponse = Support.makeRawApiResponse
let makeRawApiJsonResponse = Support.makeRawApiJsonResponse
let makeStats = Support.makeStats
let makeRawQueryResponse = Support.makeRawQueryResponse
let makeRawVersionInfo = Support.makeRawVersionInfo
let makeRawFrame = Support.makeRawFrame
let makeRawValueFrame = Support.makeRawValueFrame
let makeRawErrorFrame = Support.makeRawErrorFrame
let makeRawDoneFrame = Support.makeRawDoneFrame
let makeServerError = Support.makeServerError
let toUnknown = SurrealdbTestCasts.toUnknown

Vitest.describe("SurrealDB runtime type surface", () => {
  Vitest.test("plain-object response, token, stats, query-response, and js-value surfaces stay honest", t => {
    let tokens = Surrealdb_Tokens.make(~access="access-token", ~refresh="refresh-token", ())
    let apiResponse =
      makeRawApiResponse(
        ~body=Nullable.make(Surrealdb_JsValue.string("alpha")->toUnknown),
        ~headers=Nullable.make(Dict.fromArray([("content-type", "application/json")])),
        ~status=Nullable.make(201),
        (),
      )
    let apiJsonResponse =
      makeRawApiJsonResponse(
        ~body=Nullable.make(JSON.Encode.object(Dict.fromArray([("ok", JSON.Encode.bool(true))]))),
        ~headers=Nullable.make(Dict.fromArray([("content-type", "application/json")])),
        ~status=Nullable.make(202),
        (),
      )
    let stats = makeStats()
    let queryResponse =
      makeRawQueryResponse(
        ~success=true,
        ~result=Nullable.make(Surrealdb_JsValue.int(7)->toUnknown),
        ~stats=Nullable.make(stats),
        ~type_=Nullable.make("other"),
        (),
      )
    let versionInfo = makeRawVersionInfo(~version="surrealdb-2.3.1", ())
    let bindings =
      Surrealdb_JsValue.bindings([
        ("name", Surrealdb_JsValue.String("alpha")),
        ("count", Surrealdb_JsValue.Int(3)),
        ("ratio", Surrealdb_JsValue.Float(1.5)),
        ("enabled", Surrealdb_JsValue.Bool(true)),
        ("id", Surrealdb_JsValue.Record(Surrealdb_RecordId.make("widgets", "alpha"))),
      ])

    t->Vitest.expect((
      tokens->Surrealdb_Tokens.access,
      tokens->Surrealdb_Tokens.refresh,
      tokens->Surrealdb_Tokens.toJSON->jsonText,
      apiResponse->Surrealdb_ApiResponse.body->Option.map(Surrealdb_Value.toText),
      apiResponse->Surrealdb_ApiResponse.headers,
      apiResponse->Surrealdb_ApiResponse.status,
      apiResponse->Surrealdb_ApiResponse.toJSON->jsonText,
      apiJsonResponse->Surrealdb_ApiJsonResponse.body->Option.map(jsonText),
      apiJsonResponse->Surrealdb_ApiJsonResponse.headers,
      apiJsonResponse->Surrealdb_ApiJsonResponse.status,
      apiJsonResponse->Surrealdb_ApiJsonResponse.toJSON->jsonText,
      stats->Surrealdb_QueryStats.recordsReceived,
      stats->Surrealdb_QueryStats.bytesReceived,
      stats->Surrealdb_QueryStats.recordsScanned,
      stats->Surrealdb_QueryStats.bytesScanned,
      stats->Surrealdb_QueryStats.duration->Surrealdb_Duration.toString,
      stats->Surrealdb_QueryStats.toJSON->jsonText,
      queryResponse->Surrealdb_QueryResponse.success,
      queryResponse->Surrealdb_QueryResponse.result->Option.map(Surrealdb_Value.toText),
      queryResponse->Surrealdb_QueryResponse.stats->Option.map(Surrealdb_QueryStats.recordsReceived),
      queryResponse->Surrealdb_QueryResponse.type_,
      versionInfo->Surrealdb_VersionInfo.version,
      Surrealdb_JsValue.string("alpha")->toUnknown->Surrealdb_Value.fromUnknown->Surrealdb_Value.toText,
      Surrealdb_JsValue.int(3)->toUnknown->Surrealdb_Value.fromUnknown->Surrealdb_Value.toText,
      Surrealdb_JsValue.float(1.5)->toUnknown->Surrealdb_Value.fromUnknown->Surrealdb_Value.toText,
      Surrealdb_JsValue.bool(true)->toUnknown->Surrealdb_Value.fromUnknown->Surrealdb_Value.toText,
      bindings->Dict.toArray->Array.length,
      bindings->Dict.get("id")->Option.map(value => value->toUnknown->Surrealdb_Value.fromUnknown->Surrealdb_Value.toText),
      Surrealdb_JsValue.emptyBindings->Dict.toArray->Array.length,
    ))->Vitest.Expect.toEqual((
      "access-token",
      Some("refresh-token"),
      "{\"access\":\"access-token\",\"refresh\":\"refresh-token\"}",
      Some("alpha"),
      Some(Dict.fromArray([("content-type", "application/json")])),
      Some(201),
      "{\"status\":201,\"headers\":{\"content-type\":\"application/json\"},\"body\":\"alpha\"}",
      Some("{\"ok\":true}"),
      Some(Dict.fromArray([("content-type", "application/json")])),
      Some(202),
      "{\"status\":202,\"headers\":{\"content-type\":\"application/json\"},\"body\":{\"ok\":true}}",
      1,
      2,
      3,
      4,
      "5ms",
      "{\"recordsReceived\":1,\"bytesReceived\":2,\"recordsScanned\":3,\"bytesScanned\":4,\"duration\":\"5ms\"}",
      true,
      Some("7"),
      Some(1),
      Some(Surrealdb_QueryType.Other),
      "surrealdb-2.3.1",
      "alpha",
      "3",
      "1.5",
      "true",
      5,
      Some("widgets:alpha"),
      0,
    ))
  })

  Vitest.testAsync("feature, engine, frame, query-frame, and json-frame surfaces stay executable", async t => {
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
    let context = Surrealdb_DriverContext.make(~options, ~uniqueId=(() => "coverage-engine"), ~codecs=codecRegistry)
    let wsEngine = context->Surrealdb_DriverContext.instantiate(engines->Surrealdb_RemoteEngines.ws)
    wsEngine->Surrealdb_Engine.ready
    try {
      await wsEngine->Surrealdb_Engine.close
    } catch {
    | _ => ()
    }

    let stats = makeStats()
    let serverError = makeServerError()
    let plainFrame = makeRawFrame(1)
    let valueFrame = makeRawValueFrame(2, Surrealdb_JsValue.string("alpha")->toUnknown, true)
    let errorFrame = makeRawErrorFrame(3, Nullable.make(stats), serverError)
    let doneFrame = makeRawDoneFrame(4, Nullable.make(stats), "other")
    let jsonValueFrame =
      makeRawValueFrame(
        5,
        JSON.Encode.object(Dict.fromArray([("label", JSON.Encode.string("alpha"))]))->toUnknown,
        false,
      )
    let thrownMessage =
      try {
        ignore(
          errorFrame
          ->toUnknown
          ->Surrealdb_QueryFrame.fromUnknown
          ->Option.getOrThrow(~message="missing")
          ->Surrealdb_QueryFrame.asError
          ->Option.getOrThrow(~message="missing")
          ->Surrealdb_QueryFrame.throw_,
        )
        "<missing>"
      } catch {
      | JsExn(error) => error->JsExn.message->Option.getOr("")
      }

    t->Vitest.expect((
      engines->Surrealdb_RemoteEngines.keys,
      wsEngine->Surrealdb_Engine.features->Array.map(Surrealdb_Feature.name),
      wsEngine->Surrealdb_Engine.featuresSet->Surrealdb_Engine.arrayFromSet->Array.length,
      Surrealdb_Features.liveQueries->Surrealdb_Feature.name,
      Surrealdb_Features.all->Surrealdb_Features.liveQueries_->Surrealdb_Feature.name,
      Surrealdb_Features.all->Surrealdb_Features.sessions_->Surrealdb_Feature.name,
      Surrealdb_Features.all->Surrealdb_Features.api_->Surrealdb_Feature.name,
      Surrealdb_Features.all->Surrealdb_Features.refreshTokens_->Surrealdb_Feature.name,
      Surrealdb_Features.all->Surrealdb_Features.transactions_->Surrealdb_Feature.name,
      Surrealdb_Features.all->Surrealdb_Features.exportImportRaw_->Surrealdb_Feature.name,
      Surrealdb_Features.all->Surrealdb_Features.surrealMl_->Surrealdb_Feature.name,
      Surrealdb_Features.values()->Array.length,
      Surrealdb_Features.fromString("surreal-ml")->Option.map(Surrealdb_Feature.name),
      Surrealdb_Features.liveQueries->Surrealdb_Feature.sinceVersion,
      Surrealdb_Features.liveQueries->Surrealdb_Feature.untilVersion,
      Surrealdb_Features.liveQueries->Surrealdb_Feature.toJSON->jsonText->String.includes("\"name\":\"live-queries\""),
      Surrealdb_Features.liveQueries->toUnknown->Surrealdb_Feature.isInstance,
      plainFrame->toUnknown->Surrealdb_Frame.fromUnknown->Option.isSome,
      valueFrame->toUnknown->Surrealdb_Frame.fromUnknown->Option.flatMap(Surrealdb_Frame.asValue)->Option.map(Surrealdb_Frame.valueIsSingle),
      errorFrame
      ->toUnknown
      ->Surrealdb_Frame.fromUnknown
      ->Option.flatMap(Surrealdb_Frame.asError)
      ->Option.flatMap(Surrealdb_Frame.stats)
      ->Option.map(Surrealdb_QueryStats.bytesReceived),
      doneFrame
      ->toUnknown
      ->Surrealdb_Frame.fromUnknown
      ->Option.flatMap(Surrealdb_Frame.asDone)
      ->Option.flatMap(Surrealdb_Frame.doneStats)
      ->Option.map(Surrealdb_QueryStats.recordsScanned),
      doneFrame
      ->toUnknown
      ->Surrealdb_Frame.fromUnknown
      ->Option.flatMap(Surrealdb_Frame.asDone)
      ->Option.map(Surrealdb_Frame.doneType),
      valueFrame
      ->toUnknown
      ->Surrealdb_Frame.fromUnknown
      ->Option.map(Surrealdb_Frame.toJSON)
      ->Option.map(jsonText)
      ->Option.getOr("")
      ->String.includes("\"frameType\":\"value\""),
      errorFrame
      ->toUnknown
      ->Surrealdb_Frame.fromUnknown
      ->Option.map(Surrealdb_Frame.toJSON)
      ->Option.map(jsonText)
      ->Option.getOr("")
      ->String.includes("\"frameType\":\"error\""),
      doneFrame
      ->toUnknown
      ->Surrealdb_Frame.fromUnknown
      ->Option.map(Surrealdb_Frame.toJSON)
      ->Option.map(jsonText)
      ->Option.getOr("")
      ->String.includes("\"frameType\":\"done\""),
      valueFrame->toUnknown->Surrealdb_QueryFrame.fromUnknown->Option.flatMap(Surrealdb_QueryFrame.asValue)->Option.map(Surrealdb_QueryFrame.value)->Option.map(Surrealdb_Value.toText),
      errorFrame->toUnknown->Surrealdb_QueryFrame.fromUnknown->Option.flatMap(Surrealdb_QueryFrame.asError)->Option.map(Surrealdb_QueryFrame.errorValue)->Option.map(Surrealdb_ServerError.kind),
      doneFrame->toUnknown->Surrealdb_QueryFrame.fromUnknown->Option.flatMap(Surrealdb_QueryFrame.asDone)->Option.map(Surrealdb_QueryFrame.doneType),
      jsonValueFrame->toUnknown->Surrealdb_JsonFrame.fromUnknown->Option.flatMap(Surrealdb_JsonFrame.asValue)->Option.map(Surrealdb_JsonFrame.value)->Option.map(jsonText),
      thrownMessage->String.includes("Synthetic timeout"),
    ))->Vitest.Expect.toEqual((
      ["ws", "wss", "http", "https"],
      ["live-queries", "refresh-tokens", "sessions", "transactions", "api", "export-import-raw", "surreal-ml"],
      7,
      "live-queries",
      "live-queries",
      "sessions",
      "api",
      "refresh-tokens",
      "transactions",
      "export-import-raw",
      "surreal-ml",
      7,
      Some("surreal-ml"),
      None,
      None,
      true,
      true,
      true,
      Some(true),
      Some(2),
      Some(3),
      Some(Surrealdb_QueryType.Other),
      true,
      true,
      true,
      Some("alpha"),
      Some(Surrealdb_ErrorKind.query),
      Some(Surrealdb_QueryType.Other),
      Some("{\"label\":\"alpha\"}"),
      true,
    ))
  })
})
