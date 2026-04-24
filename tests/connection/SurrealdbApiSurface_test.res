module Support = SurrealdbSessionTestSupport

let closeIgnore = Support.closeIgnore
let connectServerDatabase = Support.connectServerDatabase
let compiledApiRequestFieldText = Support.compiledApiRequestFieldText
let compiledApiRequestFieldJson = Support.compiledApiRequestFieldJson
let makeRawApiResponse = Support.makeRawApiResponse
let removeTableIgnore = Support.removeTableIgnore
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

})
