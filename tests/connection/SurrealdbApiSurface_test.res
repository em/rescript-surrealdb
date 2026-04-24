module Support = SurrealdbSessionTestSupport
module CoverageSupport = SurrealdbCoverageTestSupport

let closeIgnore = Support.closeIgnore
let connectServerDatabase = Support.connectServerDatabase
let compiledApiRequestFieldText = Support.compiledApiRequestFieldText
let compiledApiRequestFieldJson = Support.compiledApiRequestFieldJson
let makeRawApiResponse = Support.makeRawApiResponse
let removeTableIgnore = Support.removeTableIgnore
let makeDisconnectedDb = CoverageSupport.makeDisconnectedDb
let toUnknown = SurrealdbTestCasts.toUnknown

Vitest.describe("SurrealDB API surface", () => {
  Vitest.testAsync("api promises are directly awaitable and value() rejects unsuccessful responses", async t => {
    let db = Surrealdb_Surreal.make()
    try {
      await connectServerDatabase(db)

      let api = db->Surrealdb_Surreal.asQueryable->Surrealdb_Api.fromQueryable
      let response = await api->Surrealdb_Api.get_("/missing")->Surrealdb_ApiPromise.resolve
      let rejected =
        try {
          let _ =
            await api
            ->Surrealdb_Api.get_("/missing")
            ->Surrealdb_ApiPromise.value
            ->Surrealdb_ApiPromise.awaitValue
          "no rejection"
        } catch {
        | JsExn(jsError) =>
          switch jsError->toUnknown->Surrealdb_ClientError.asUnsuccessfulApi {
          | Some(value) =>
            `${value->Surrealdb_ClientError.unsuccessfulApiMethod}:${value->Surrealdb_ClientError.unsuccessfulApiPath}:${value->Surrealdb_ClientError.unsuccessfulApiResponse->Surrealdb_ApiResponse.status->Option.getOr(0)->Int.toString}`
          | None => jsError->JsExn.message->Option.getOr("unexpected js error")
          }
        | _ => "unexpected non-js error"
        }

      t->Vitest.expect((
        response->Surrealdb_ApiResponse.status,
        response->Surrealdb_ApiResponse.body->Option.map(Surrealdb_Value.toText),
        rejected,
      ))->Vitest.Expect.toEqual((
        Some(404),
        Some("Not found"),
        "get:/missing:404",
      ))

      await closeIgnore(db)
    } catch {
    | error =>
      await closeIgnore(db)
      throw(error)
    }
  })

  Vitest.testAsync("api promise then_ delivers the installed response type into the callback", async t => {
    let db = Surrealdb_Surreal.make()
    let callbackStatus = ref(None)
    let callbackBody = ref(None)
    try {
      await connectServerDatabase(db)

      let api = db->Surrealdb_Surreal.asQueryable->Surrealdb_Api.fromQueryable
      let response =
        await api
        ->Surrealdb_Api.get_("/missing")
        ->Surrealdb_ApiPromise.then_(response => {
            callbackStatus.contents = response->Surrealdb_ApiResponse.status
            callbackBody.contents =
              response->Surrealdb_ApiResponse.body->Option.map(Surrealdb_Value.toText)
            response
          })

      t->Vitest.expect((
        callbackStatus.contents,
        callbackBody.contents,
        response->Surrealdb_ApiResponse.status,
        response->Surrealdb_ApiResponse.body->Option.map(Surrealdb_Value.toText),
      ))->Vitest.Expect.toEqual((Some(404), Some("Not found"), Some(404), Some("Not found")))

      await closeIgnore(db)
    } catch {
    | error =>
      await closeIgnore(db)
      throw(error)
    }
  })

  Vitest.testAsync("json-mode builders resolve explicit JSON payloads on query, select, and API responses", async t => {
    let db = Surrealdb_Surreal.make()
    let tableName = "json_mode_items"
    let recordId = Surrealdb_RecordId.make(tableName, "alpha")
    let createdAt = Surrealdb_DateTime.fromString("2024-01-02T03:04:05Z")
    try {
      await connectServerDatabase(db)
      await removeTableIgnore(db, tableName)
      ignore(await db->Surrealdb_Query.runText(`DEFINE TABLE ${tableName} SCHEMALESS;`))

      let queryable = db->Surrealdb_Surreal.asQueryable
      ignore(
        await queryable
        ->Surrealdb_Create.fromRecordIdOn(recordId)
        ->Surrealdb_Create.content(
            Dict.fromArray([
              ("label", Surrealdb_JsValue.string("alpha")),
              ("createdAt", createdAt->Surrealdb_JsValue.dateTime),
            ]),
          )
        ->Surrealdb_Create.resolve
      )

      let queryJson =
        await db
        ->Surrealdb_Query.text("RETURN d\"2024-01-02T03:04:05.000Z\";", ())
        ->Surrealdb_Query.json
        ->Surrealdb_Query.resolveJson
      let selectJson =
        await queryable
        ->Surrealdb_Select.fromRecordIdOn(recordId)
        ->Surrealdb_Select.json
        ->Surrealdb_Select.resolveJson
      let apiJson =
        await queryable
        ->Surrealdb_Api.fromQueryable
        ->Surrealdb_Api.get_("/missing")
        ->Surrealdb_ApiPromise.json
        ->Surrealdb_ApiPromise.resolveJson

      t->Vitest.expect((
        queryJson->Array.get(0)->Option.flatMap(value => value->JSON.stringifyAny),
        selectJson->JSON.stringifyAny,
        apiJson->Surrealdb_ApiJsonResponse.status,
        apiJson->Surrealdb_ApiJsonResponse.body->Option.flatMap(value => value->JSON.stringifyAny),
      ))->Vitest.Expect.toEqual((
        Some("\"2024-01-02T03:04:05.000Z\""),
        Some("{\"createdAt\":\"2024-01-02T03:04:05.000Z\",\"id\":\"json_mode_items:alpha\",\"label\":\"alpha\"}"),
        Some(404),
        Some("\"Not found\""),
      ))

      await removeTableIgnore(db, tableName)
      await closeIgnore(db)
    } catch {
    | error =>
      await removeTableIgnore(db, tableName)
      await closeIgnore(db)
      throw(error)
    }
  })

  Vitest.testAsync("api request builders and promise modifiers stay explicit on the public surface", async t => {
    let db = Surrealdb_Surreal.make()
    try {
      await connectServerDatabase(db)

      let api = db->Surrealdb_Surreal.asQueryable->Surrealdb_Api.fromQueryableWithPrefix("/root")
      api->Surrealdb_Api.setHeader("x-default", "a")
      let compiledGet =
        api
        ->Surrealdb_Api.get_("/widgets")
        ->Surrealdb_ApiPromise.header("x-one", "1")
        ->Surrealdb_ApiPromise.query("page", "2")
        ->Surrealdb_ApiPromise.value
        ->Surrealdb_ApiPromise.compile
      api->Surrealdb_Api.clearHeader("x-default")
      let compiledInvoke =
        api
        ->Surrealdb_Api.invoke(
            "/widgets",
            ~method=Surrealdb_Api.Post,
            ~body=JSON.parseOrThrow("{\"title\":\"alpha\"}")->Surrealdb_JsValue.json,
            ~headers=Dict.fromArray([("x-test", "1")]),
            ~query=Dict.fromArray([("page", "2")]),
            (),
          )
        ->Surrealdb_ApiPromise.json
        ->Surrealdb_ApiPromise.compile
      let compiledDelete = api->Surrealdb_Api.delete_("/widgets", ())->Surrealdb_ApiPromise.compile
      let compiledPatch =
        api
        ->Surrealdb_Api.patch(
            "/widgets",
            ~body=JSON.parseOrThrow("{\"title\":\"beta\"}")->Surrealdb_JsValue.json,
            (),
          )
        ->Surrealdb_ApiPromise.compile
      let compiledTrace = api->Surrealdb_Api.trace("/widgets", ())->Surrealdb_ApiPromise.compile

      t->Vitest.expect((
        compiledGet->compiledApiRequestFieldText("method"),
        compiledGet->compiledApiRequestFieldJson("headers"),
        compiledGet->compiledApiRequestFieldJson("query"),
        compiledInvoke->compiledApiRequestFieldText("method"),
        compiledInvoke->compiledApiRequestFieldJson("headers"),
        compiledInvoke->compiledApiRequestFieldJson("query"),
        compiledInvoke->compiledApiRequestFieldJson("body"),
        compiledDelete->compiledApiRequestFieldText("method"),
        compiledPatch->compiledApiRequestFieldText("method"),
        compiledTrace->compiledApiRequestFieldText("method"),
      ))->Vitest.Expect.toEqual((
        Some("get"),
        Some("{\"x-default\":\"a\",\"x-one\":\"1\"}"),
        Some("{\"page\":\"2\"}"),
        Some("post"),
        Some("{\"x-test\":\"1\"}"),
        Some("{\"page\":\"2\"}"),
        Some("{\"title\":\"alpha\"}"),
        Some("delete"),
        Some("patch"),
        Some("trace"),
      ))

      await closeIgnore(db)
    } catch {
    | error =>
      await closeIgnore(db)
      throw(error)
    }
  })

  Vitest.testAsync("api request builders cover the raw method and body variants on the public surface", async t => {
    let db = Surrealdb_Surreal.make()
    try {
      await connectServerDatabase(db)

      let api = db->Surrealdb_Surreal.asQueryable->Surrealdb_Api.fromQueryableWithPrefix("/root")
      let request =
        Surrealdb_Api.makeRequest(
          ~method=Surrealdb_Api.Put,
          ~body=JSON.parseOrThrow("{\"title\":\"alpha\"}")->Surrealdb_JsValue.json,
          ~headers=Dict.fromArray([("x-test", "1")]),
          ~query=Dict.fromArray([("page", "2")]),
          (),
        )
      let compiledInvokePath = api->Surrealdb_Api.invokePath("/widgets")->Surrealdb_ApiPromise.compile
      let compiledInvokeRaw = api->Surrealdb_Api.invokeRaw("/widgets", request)->Surrealdb_ApiPromise.compile
      let compiledGet = api->Surrealdb_Api.get_("/widgets")->Surrealdb_ApiPromise.compile
      let compiledPost = api->Surrealdb_Api.post_("/widgets")->Surrealdb_ApiPromise.compile
      let compiledPostRaw =
        api
        ->Surrealdb_Api.postRaw("/widgets", JSON.parseOrThrow("{\"title\":\"beta\"}")->Surrealdb_JsValue.json)
        ->Surrealdb_ApiPromise.compile
      let compiledPut = api->Surrealdb_Api.put_("/widgets")->Surrealdb_ApiPromise.compile
      let compiledPutRaw =
        api
        ->Surrealdb_Api.putRaw("/widgets", JSON.parseOrThrow("{\"title\":\"gamma\"}")->Surrealdb_JsValue.json)
        ->Surrealdb_ApiPromise.compile
      let compiledDelete = api->Surrealdb_Api.delete_("/widgets", ())->Surrealdb_ApiPromise.compile
      let compiledDeleteRaw =
        api
        ->Surrealdb_Api.deleteRaw("/widgets", JSON.parseOrThrow("{\"title\":\"delta\"}")->Surrealdb_JsValue.json)
        ->Surrealdb_ApiPromise.compile
      let compiledPatch = api->Surrealdb_Api.patch("/widgets", ())->Surrealdb_ApiPromise.compile
      let compiledPatchRaw =
        api
        ->Surrealdb_Api.patchRaw("/widgets", JSON.parseOrThrow("{\"title\":\"epsilon\"}")->Surrealdb_JsValue.json)
        ->Surrealdb_ApiPromise.compile
      let compiledTrace = api->Surrealdb_Api.trace("/widgets", ())->Surrealdb_ApiPromise.compile
      let compiledTraceRaw =
        api
        ->Surrealdb_Api.traceRaw("/widgets", JSON.parseOrThrow("{\"title\":\"zeta\"}")->Surrealdb_JsValue.json)
        ->Surrealdb_ApiPromise.compile

      t->Vitest.expect((
        compiledInvokePath->compiledApiRequestFieldText("method"),
        compiledInvokeRaw->compiledApiRequestFieldText("method"),
        compiledInvokeRaw->compiledApiRequestFieldJson("body"),
        compiledInvokeRaw->compiledApiRequestFieldJson("headers"),
        compiledInvokeRaw->compiledApiRequestFieldJson("query"),
        compiledGet->compiledApiRequestFieldText("method"),
        compiledPost->compiledApiRequestFieldText("method"),
        compiledPostRaw->compiledApiRequestFieldText("method"),
        compiledPostRaw->compiledApiRequestFieldJson("body"),
        compiledPut->compiledApiRequestFieldText("method"),
        compiledPutRaw->compiledApiRequestFieldText("method"),
        compiledPutRaw->compiledApiRequestFieldJson("body"),
        compiledDelete->compiledApiRequestFieldText("method"),
        compiledDeleteRaw->compiledApiRequestFieldText("method"),
        compiledDeleteRaw->compiledApiRequestFieldJson("body"),
        compiledPatch->compiledApiRequestFieldText("method"),
        compiledPatchRaw->compiledApiRequestFieldText("method"),
        compiledPatchRaw->compiledApiRequestFieldJson("body"),
        compiledTrace->compiledApiRequestFieldText("method"),
        compiledTraceRaw->compiledApiRequestFieldText("method"),
        compiledTraceRaw->compiledApiRequestFieldJson("body"),
      ))->Vitest.Expect.toEqual((
        Some("get"),
        Some("put"),
        Some("{\"title\":\"alpha\"}"),
        Some("{\"x-test\":\"1\"}"),
        Some("{\"page\":\"2\"}"),
        Some("get"),
        Some("post"),
        Some("post"),
        Some("{\"title\":\"beta\"}"),
        Some("put"),
        Some("put"),
        Some("{\"title\":\"gamma\"}"),
        Some("delete"),
        Some("delete"),
        Some("{\"title\":\"delta\"}"),
        Some("patch"),
        Some("patch"),
        Some("{\"title\":\"epsilon\"}"),
        Some("trace"),
        Some("trace"),
        Some("{\"title\":\"zeta\"}"),
      ))

      await closeIgnore(db)
    } catch {
    | error =>
      await closeIgnore(db)
      throw(error)
    }
  })

})
