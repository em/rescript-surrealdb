module CompileSupport = SurrealdbSessionTestSupport

let compiledApiRequestFieldText = CompileSupport.compiledApiRequestFieldText
let compiledApiRequestFieldJson = CompileSupport.compiledApiRequestFieldJson
let closeIgnore = CompileSupport.closeIgnore
let connectServerDatabase = CompileSupport.connectServerDatabase
let makeRawApiResponse = CompileSupport.makeRawApiResponse
let toUnknown = SurrealdbTestCasts.toUnknown

Vitest.describe("SurrealDB API compile surface", () => {
  Vitest.testAsync("api makeRequest narrows the request method to the closed enum surface", async t => {
    let db = Surrealdb_Surreal.make()
    try {
      await connectServerDatabase(db)

      let compiled =
        db
        ->Surrealdb_Surreal.asQueryable
        ->Surrealdb_Api.fromQueryable
        ->Surrealdb_Api.invokeRaw(
            "/widgets",
            Surrealdb_Api.makeRequest(
              ~method=Surrealdb_Api.Trace,
              ~headers=Dict.fromArray([("x-test", "1")]),
              ~query=Dict.fromArray([("page", "2")]),
              (),
            ),
          )
        ->Surrealdb_ApiPromise.compile

      t->Vitest.expect((
        compiled->compiledApiRequestFieldText("method"),
        compiled->compiledApiRequestFieldJson("headers"),
        compiled->compiledApiRequestFieldJson("query"),
      ))->Vitest.Expect.toEqual((
        Some("trace"),
        Some("{\"x-test\":\"1\"}"),
        Some("{\"page\":\"2\"}"),
      ))

      await closeIgnore(db)
    } catch {
    | error =>
      await closeIgnore(db)
      throw(error)
    }
  })

  Vitest.testAsync("api methods allow omitted request bodies on the installed public SDK surface", async t => {
    let db = Surrealdb_Surreal.make()
    let requestInfo = compiled =>
      switch compiled->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.get(1) {
      | Some((_key, value)) =>
        switch value->toUnknown->Surrealdb_Value.fromUnknown {
        | Object(entries) =>
          entries->Dict.get("method")->Option.map(Surrealdb_Value.toText)
        | _ => None
        }
      | None => None
      }
    try {
      await connectServerDatabase(db)

      let api = db->Surrealdb_Surreal.asQueryable->Surrealdb_Api.fromQueryableWithPrefix("/x")
      t->Vitest.expect((
        api->Surrealdb_Api.invoke("/y", ())->Surrealdb_ApiPromise.compile->requestInfo,
        api->Surrealdb_Api.post("/y", ())->Surrealdb_ApiPromise.compile->requestInfo,
        api->Surrealdb_Api.put("/y", ())->Surrealdb_ApiPromise.compile->requestInfo,
        api->Surrealdb_Api.delete_("/y", ())->Surrealdb_ApiPromise.compile->requestInfo,
        api->Surrealdb_Api.patch("/y", ())->Surrealdb_ApiPromise.compile->requestInfo,
        api->Surrealdb_Api.trace("/y", ())->Surrealdb_ApiPromise.compile->requestInfo,
      ))->Vitest.Expect.toEqual((
        Some("get"),
        Some("post"),
        Some("put"),
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

  Vitest.testAsync("api invoke compiles method, body, headers, and query params through the public request surface", async t => {
    let db = Surrealdb_Surreal.make()
    try {
      await connectServerDatabase(db)

      let compiled =
        db
        ->Surrealdb_Surreal.asQueryable
        ->Surrealdb_Api.fromQueryable
        ->Surrealdb_Api.invoke(
            "/widgets",
            ~method=Surrealdb_Api.Post,
            ~body=JSON.parseOrThrow("{\"title\":\"alpha\"}")->Surrealdb_JsValue.json,
            ~headers=Dict.fromArray([("x-test", "1")]),
            ~query=Dict.fromArray([("page", "2")]),
            (),
          )
        ->Surrealdb_ApiPromise.compile

      t->Vitest.expect((
        compiled->compiledApiRequestFieldText("method"),
        compiled->compiledApiRequestFieldJson("headers"),
        compiled->compiledApiRequestFieldJson("query"),
        compiled->compiledApiRequestFieldJson("body"),
      ))->Vitest.Expect.toEqual((
        Some("post"),
        Some("{\"x-test\":\"1\"}"),
        Some("{\"page\":\"2\"}"),
        Some("{\"title\":\"alpha\"}"),
      ))

      await closeIgnore(db)
    } catch {
    | error =>
      await closeIgnore(db)
      throw(error)
    }
  })

  Vitest.testAsync("api default headers and request modifiers compile through the installed public surface", async t => {
    let db = Surrealdb_Surreal.make()
    try {
      await connectServerDatabase(db)

      let api = db->Surrealdb_Surreal.asQueryable->Surrealdb_Api.fromQueryableWithPrefix("/root")
      api->Surrealdb_Api.setHeader("x-default", "a")
      let compiledDefault = api->Surrealdb_Api.get_("/path")->Surrealdb_ApiPromise.compile
      api->Surrealdb_Api.clearHeader("x-default")
      let compiledCleared = api->Surrealdb_Api.get_("/path")->Surrealdb_ApiPromise.compile
      let compiledRequest =
        db
        ->Surrealdb_Surreal.asQueryable
        ->Surrealdb_Api.fromQueryableWithPrefix("/root")
        ->Surrealdb_Api.get_("/path")
        ->Surrealdb_ApiPromise.header("x-one", "1")
        ->Surrealdb_ApiPromise.query("page", "2")
        ->Surrealdb_ApiPromise.json
        ->Surrealdb_ApiPromise.compile

      t->Vitest.expect((
        compiledDefault->compiledApiRequestFieldText("method"),
        compiledDefault->compiledApiRequestFieldJson("headers"),
        compiledDefault->compiledApiRequestFieldJson("query"),
        compiledCleared->compiledApiRequestFieldJson("headers"),
        compiledRequest->compiledApiRequestFieldJson("headers"),
        compiledRequest->compiledApiRequestFieldJson("query"),
      ))->Vitest.Expect.toEqual((
        Some("get"),
        Some("{\"x-default\":\"a\"}"),
        Some("{}"),
        Some("{}"),
        Some("{\"x-one\":\"1\"}"),
        Some("{\"page\":\"2\"}"),
      ))

      await closeIgnore(db)
    } catch {
    | error =>
      await closeIgnore(db)
      throw(error)
    }
  })

  Vitest.test("api response accessors keep optional fields honest", t => {
    let headers = Dict.fromArray([("x-one", "1")])
    let empty = makeRawApiResponse()
    let nullish =
      makeRawApiResponse(~body=Nullable.null, ~headers=Nullable.null, ~status=Nullable.null, ())
    let present =
      makeRawApiResponse(
        ~body=Nullable.make("alpha"->toUnknown),
        ~headers=Nullable.make(headers),
        ~status=Nullable.make(201),
        (),
      )

    t->Vitest.expect((
      empty->Surrealdb_ApiResponse.status,
      empty->Surrealdb_ApiResponse.headers->Option.isSome,
      empty->Surrealdb_ApiResponse.body->Option.isSome,
      nullish->Surrealdb_ApiResponse.status,
      nullish->Surrealdb_ApiResponse.headers->Option.isSome,
      nullish->Surrealdb_ApiResponse.body->Option.isSome,
      present->Surrealdb_ApiResponse.status,
      present->Surrealdb_ApiResponse.headers->Option.flatMap(headers => headers->Dict.get("x-one")),
      present->Surrealdb_ApiResponse.body->Option.map(Surrealdb_Value.toText),
    ))->Vitest.Expect.toEqual((None, false, false, None, false, false, Some(201), Some("1"), Some("alpha")))
  })
})
