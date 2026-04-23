open TestRuntime
external toUnknown: 'a => unknown = "%identity"
@obj
external makeRawApiResponse: (
  ~body: Nullable.t<unknown>=?,
  ~headers: Nullable.t<dict<string>>=?,
  ~status: Nullable.t<int>=?,
  unit,
) => Surrealdb_ApiResponse.t = ""
@get external responseStatus: Webapi.Fetch.Response.t => int = "status"

let closeIgnore = db =>
  db
  ->Surrealdb_Surreal.close
  ->Promise.then(_ => Promise.resolve())
  ->Promise.catch(_ => Promise.resolve())

let removeTableIgnore = (db, tableName) =>
  db
  ->Surrealdb_Query.runText(`REMOVE TABLE ${tableName};`)
  ->Promise.then(_ => Promise.resolve())
  ->Promise.catch(_ => Promise.resolve())

let objectIntFieldText = (value, fieldName) =>
  switch value {
  | Surrealdb_Value.Object(entries) => entries->Dict.get(fieldName)->Option.map(Surrealdb_Value.toText)
  | Surrealdb_Value.None => None
  | _ => Some("<unexpected>")
  }

let diagnosticPhase = event =>
  switch event {
  | Surrealdb_Value.Object(entries) =>
    switch (
      entries->Dict.get("type")->Option.map(Surrealdb_Value.toText),
      entries->Dict.get("phase")->Option.map(Surrealdb_Value.toText),
    ) {
    | (Some(type_), Some(phase)) => Some((type_, phase))
    | _ => None
    }
  | _ => None
  }

let compiledApiRequest = compiled =>
  compiled
  ->Surrealdb_BoundQuery.bindings
  ->Dict.toArray
  ->Belt.Array.keepMap(((_key, value)) =>
      switch value->toUnknown->Surrealdb_Value.fromUnknown {
      | Object(entries) => entries->Dict.get("method")->Option.map(_ => Surrealdb_Value.Object(entries))
      | _ => None
      }
    )
  ->Array.get(0)

let compiledApiRequestFieldText = (compiled, name) =>
  compiled
  ->compiledApiRequest
  ->Option.flatMap(value =>
      switch value {
      | Surrealdb_Value.Object(entries) => entries->Dict.get(name)
      | _ => None
      }
    )
  ->Option.map(Surrealdb_Value.toText)

let compiledApiRequestFieldJson = (compiled, name) =>
  compiled
  ->compiledApiRequest
  ->Option.flatMap(value =>
      switch value {
      | Surrealdb_Value.Object(entries) => entries->Dict.get(name)
      | _ => None
      }
    )
  ->Option.map(Surrealdb_Value.toJSON)
  ->Option.flatMap(json => JSON.stringifyAny(json))

let endpoint = () => SurrealdbTestContext.endpoint()
let namespace = () => SurrealdbTestContext.namespace()
let database = () => SurrealdbTestContext.database()
let username = () => SurrealdbTestContext.username()
let password = () => SurrealdbTestContext.password()

let rootConnectAuth = () =>
  Surrealdb_Surreal.rootConnectAuth(~username=username(), ~password=password(), ())

let rootAuthentication = () =>
  rootConnectAuth()->Surrealdb_Surreal.staticAuthentication

let rootSigninAuth = () =>
  Surrealdb_Session.rootAuth(~username=username(), ~password=password(), ())

let connectServerDatabase = db =>
  Surrealdb_Surreal.connectServerDatabase(
    db,
    endpoint(),
    namespace(),
    database(),
    username(),
    password(),
  )

let namespaceDatabaseSelection = () =>
  Surrealdb_Session.makeNamespaceDatabase(
    ~namespace=Nullable.make(namespace()),
    ~database=Nullable.make(database()),
    (),
  )

let expectedUsingSelectionJson = () =>
  Some(`{"namespace":"${namespace()}","database":"${database()}"}`)

let liveMessageSummary = message =>
  (
    message->Surrealdb_LiveMessage.queryId->Surrealdb_Uuid.toString,
    message->Surrealdb_LiveMessage.action,
    message->Surrealdb_LiveMessage.recordId->Surrealdb_RecordId.toString,
    switch message->Surrealdb_LiveMessage.value {
    | Object(entries) =>
      (
        entries->Dict.get("value")->Option.map(Surrealdb_Value.toText),
        entries->Dict.get("label")->Option.map(Surrealdb_Value.toText),
      )
    | value => (Some(`unexpected:${value->Surrealdb_Value.toText}`), None)
    },
  )

describe("SurrealDB session surface", () => {
  testAsync("connect options map to the installed public SDK surface", async () => {
    let engines = Surrealdb_RemoteEngines.create()
    let db =
      Surrealdb_Surreal.withOptions(
        ~engines,
        ~codecs=Dict.fromArray([("cbor", Surrealdb_ValueCodec.cborFactory)]),
        ~codecOptions=Surrealdb_CborCodec.makeOptions(~useNativeDates=true, ()),
        ~fetchImpl=Surrealdb_Surreal.defaultFetchImpl,
        (),
      )
    try {
      await Surrealdb_Surreal.connect(
        db,
        endpoint(),
        ~namespace=namespace(),
        ~database=database(),
        ~authentication=rootAuthentication(),
        ~versionCheck=false,
        ~invalidateOnExpiry=false,
        ~reconnect=
          Surrealdb_Surreal.makeReconnect(
            ~enabled=false,
            ~attempts=3,
            ~retryDelay=10,
            ~retryDelayMax=50,
            ~retryDelayMultiplier=2.0,
            ~retryDelayJitter=0.0,
            (),
          ),
        (),
      )

      (
        db->Surrealdb_Surreal.status,
        db->Surrealdb_Surreal.isConnected,
      )
      ->Expect.expect
      ->Expect.toEqual(("connected", true))

      await closeIgnore(db)
    } catch {
    | error =>
      await closeIgnore(db)
      throw(error)
    }
  })

  testAsync("connect auth providers map to the installed public SDK surface", async () => {
    let db = Surrealdb_Surreal.make()
    let provider = _session =>
      Promise.resolve(
        rootConnectAuth()->Surrealdb_Surreal.providedAuthFromConnectAuth,
      )
    try {
      await Surrealdb_Surreal.connect(
        db,
        endpoint(),
        ~namespace=namespace(),
        ~database=database(),
        ~authentication=Surrealdb_Surreal.asyncAuthenticationProvider(provider),
        ~versionCheck=false,
        (),
      )

      (
        db->Surrealdb_Surreal.status,
        db->Surrealdb_Surreal.isConnected,
      )
      ->Expect.expect
      ->Expect.toEqual(("connected", true))

      await closeIgnore(db)
    } catch {
    | error =>
      await closeIgnore(db)
      throw(error)
    }
  })

  testAsync("remote engine diagnostics emit the installed connection lifecycle events", async () => {
    let phases = ref([])
    let db =
      Surrealdb_RemoteEngines.create()
      ->Surrealdb_RemoteEngines.applyDiagnostics(event =>
          switch event->diagnosticPhase {
          | Some(value) =>
            if Array.length(phases.contents) < 8 {
              phases.contents = Array.concat(phases.contents, [value])
            }
          | None => ()
          }
        )
      ->Surrealdb_Surreal.withRemoteEngines
    try {
      await Surrealdb_Surreal.connect(
        db,
        endpoint(),
        ~namespace=namespace(),
        ~database=database(),
        ~authentication=rootAuthentication(),
        (),
      )

      phases.contents
      ->Expect.expect
      ->Expect.toEqual([
        ("open", "before"),
        ("open", "after"),
        ("version", "before"),
        ("version", "after"),
        ("use", "before"),
        ("use", "after"),
        ("signin", "before"),
        ("signin", "after"),
      ])

      await closeIgnore(db)
    } catch {
    | error =>
      await closeIgnore(db)
      throw(error)
    }
  })

  testAsync("url-form connect and no-arg use map to the installed public SDK surface", async () => {
    let db = Surrealdb_Surreal.make()
    try {
      await Surrealdb_Surreal.connectUrl(
        db,
        Webapi.Url.make(endpoint()),
        ~namespace=namespace(),
        ~database=database(),
        ~authentication=rootAuthentication(),
        ~versionCheck=false,
        (),
      )

      let selection = await db->Surrealdb_Surreal.asSession->Surrealdb_Session.useCurrent
      (
        selection->Surrealdb_Session.namespaceValue,
        selection->Surrealdb_Session.databaseValue,
      )
      ->Expect.expect
      ->Expect.toEqual((Some(namespace()), Some(database())))

      await closeIgnore(db)
    } catch {
    | error =>
      await closeIgnore(db)
      throw(error)
    }
  })

  testAsync("health() currently surfaces the installed ws/rpc not-found failure", async () => {
    let db = Surrealdb_Surreal.make()
    try {
      await connectServerDatabase(db)

      let outcome =
        try {
          await db->Surrealdb_Surreal.health
          "no error"
        } catch {
        | JsExn(jsError) =>
          switch jsError->toUnknown->Surrealdb_ServerError.fromUnknown {
          | Some(serverError) =>
            switch serverError->Surrealdb_ServerError.asNotFound {
            | Some(_) => "not_found"
            | None => "other server error"
            }
          | None => jsError->JsExn.message->Option.getOr("unexpected js error")
          }
        | _ => "unexpected non-js error"
        }

      outcome->Expect.expect->Expect.toBe("not_found")

      await closeIgnore(db)
    } catch {
    | error =>
      await closeIgnore(db)
      throw(error)
    }
  })

  testAsync("api methods allow omitted request bodies on the installed public SDK surface", async () => {
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
      (
        api->Surrealdb_Api.invoke("/y", ())->Surrealdb_ApiPromise.compile->requestInfo,
        api->Surrealdb_Api.post("/y", ())->Surrealdb_ApiPromise.compile->requestInfo,
        api->Surrealdb_Api.put("/y", ())->Surrealdb_ApiPromise.compile->requestInfo,
        api->Surrealdb_Api.delete_("/y", ())->Surrealdb_ApiPromise.compile->requestInfo,
        api->Surrealdb_Api.patch("/y", ())->Surrealdb_ApiPromise.compile->requestInfo,
        api->Surrealdb_Api.trace("/y", ())->Surrealdb_ApiPromise.compile->requestInfo,
      )
      ->Expect.expect
      ->Expect.toEqual((
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

  testAsync("api invoke compiles method, body, headers, and query params through the public request surface", async () => {
    let db = Surrealdb_Surreal.make()
    try {
      await connectServerDatabase(db)

      let api = db->Surrealdb_Surreal.asQueryable->Surrealdb_Api.fromQueryable
      let compiled =
        api
        ->Surrealdb_Api.invoke(
            "/widgets",
            ~method=Surrealdb_Api.Post,
            ~body=JSON.parseOrThrow("{\"title\":\"alpha\"}")->Surrealdb_JsValue.json,
            ~headers=Dict.fromArray([("x-test", "1")]),
            ~query=Dict.fromArray([("page", "2")]),
            (),
          )
        ->Surrealdb_ApiPromise.compile

      (
        compiled->compiledApiRequestFieldText("method"),
        compiled->compiledApiRequestFieldJson("headers"),
        compiled->compiledApiRequestFieldJson("query"),
        compiled->compiledApiRequestFieldJson("body"),
      )
      ->Expect.expect
      ->Expect.toEqual((
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

  testAsync("api default headers and request modifiers compile through the installed public surface", async () => {
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

      (
        compiledDefault->compiledApiRequestFieldText("method"),
        compiledDefault->compiledApiRequestFieldJson("headers"),
        compiledDefault->compiledApiRequestFieldJson("query"),
        compiledCleared->compiledApiRequestFieldJson("headers"),
        compiledRequest->compiledApiRequestFieldJson("headers"),
        compiledRequest->compiledApiRequestFieldJson("query"),
      )
      ->Expect.expect
      ->Expect.toEqual((
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

  test("api response accessors keep optional fields honest", () => {
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

    (
      empty->Surrealdb_ApiResponse.status,
      empty->Surrealdb_ApiResponse.headers->Option.isSome,
      empty->Surrealdb_ApiResponse.body->Option.isSome,
      nullish->Surrealdb_ApiResponse.status,
      nullish->Surrealdb_ApiResponse.headers->Option.isSome,
      nullish->Surrealdb_ApiResponse.body->Option.isSome,
      present->Surrealdb_ApiResponse.status,
      present->Surrealdb_ApiResponse.headers->Option.flatMap(headers => headers->Dict.get("x-one")),
      present->Surrealdb_ApiResponse.body->Option.map(Surrealdb_Value.toText),
    )
    ->Expect.expect
    ->Expect.toEqual((None, false, false, None, false, false, Some(201), Some("1"), Some("alpha")))
  })

  testAsync("api promises are directly awaitable and value() rejects unsuccessful responses", async () => {
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

      (
        response->Surrealdb_ApiResponse.status,
        response->Surrealdb_ApiResponse.body->Option.map(Surrealdb_Value.toText),
        rejected,
      )
      ->Expect.expect
      ->Expect.toEqual((
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

  testAsync("api promise then_ delivers the installed response type into the callback", async () => {
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

      (
        callbackStatus.contents,
        callbackBody.contents,
        response->Surrealdb_ApiResponse.status,
        response->Surrealdb_ApiResponse.body->Option.map(Surrealdb_Value.toText),
      )
      ->Expect.expect
      ->Expect.toEqual((Some(404), Some("Not found"), Some(404), Some("Not found")))

      await closeIgnore(db)
    } catch {
    | error =>
      await closeIgnore(db)
      throw(error)
    }
  })

  testAsync("json-mode builders resolve explicit JSON payloads on query, select, and API responses", async () => {
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

      (
        queryJson->Array.get(0)->Option.flatMap(value => value->JSON.stringifyAny),
        selectJson->JSON.stringifyAny,
        apiJson->Surrealdb_ApiJsonResponse.status,
        apiJson->Surrealdb_ApiJsonResponse.body->Option.flatMap(value => value->JSON.stringifyAny),
      )
      ->Expect.expect
      ->Expect.toEqual((
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

  testAsync("transactions expose shared queryable behavior across commit and cancel", async () => {
    let db = Surrealdb_Surreal.make()
    let tableName = "tx_items"
    let committedId = Surrealdb_RecordId.make(tableName, "from_tx")
    let cancelledId = Surrealdb_RecordId.make(tableName, "cancelled")
    try {
      await connectServerDatabase(db)

      await removeTableIgnore(db, tableName)
      ignore(await db->Surrealdb_Query.runText(`DEFINE TABLE ${tableName} SCHEMALESS;`))

      let committedTx = await db->Surrealdb_Surreal.beginTransaction
      let committedQueryable = committedTx->Surrealdb_Transaction.asQueryable
      ignore(
        await committedQueryable
        ->Surrealdb_Create.recordOn(tableName, "from_tx")
        ->Surrealdb_Create.content(Dict.fromArray([("value", Surrealdb_JsValue.int(1))]))
        ->Surrealdb_Create.resolve
      )
      let insideCommitted =
        await committedQueryable
        ->Surrealdb_Select.fromRecordIdOn(committedId)
        ->Surrealdb_Select.resolve
      let outsideBeforeCommit =
        await db
        ->Surrealdb_Surreal.asQueryable
        ->Surrealdb_Select.fromRecordIdOn(committedId)
        ->Surrealdb_Select.resolve
      await committedTx->Surrealdb_Transaction.commit
      let outsideAfterCommit =
        await db
        ->Surrealdb_Surreal.asQueryable
        ->Surrealdb_Select.fromRecordIdOn(committedId)
        ->Surrealdb_Select.resolve

      let cancelledTx = await db->Surrealdb_Surreal.beginTransaction
      let cancelledQueryable = cancelledTx->Surrealdb_Transaction.asQueryable
      ignore(
        await cancelledQueryable
        ->Surrealdb_Create.fromRecordIdOn(cancelledId)
        ->Surrealdb_Create.content(Dict.fromArray([("value", Surrealdb_JsValue.int(2))]))
        ->Surrealdb_Create.resolve
      )
      let insideCancelled =
        await cancelledQueryable
        ->Surrealdb_Select.fromRecordIdOn(cancelledId)
        ->Surrealdb_Select.resolve
      let outsideBeforeCancel =
        await db
        ->Surrealdb_Surreal.asQueryable
        ->Surrealdb_Select.fromRecordIdOn(cancelledId)
        ->Surrealdb_Select.resolve
      await cancelledTx->Surrealdb_Transaction.cancel
      let outsideAfterCancel =
        await db
        ->Surrealdb_Surreal.asQueryable
        ->Surrealdb_Select.fromRecordIdOn(cancelledId)
        ->Surrealdb_Select.resolve

      (
        insideCommitted->objectIntFieldText("value"),
        outsideBeforeCommit->objectIntFieldText("value"),
        outsideAfterCommit->objectIntFieldText("value"),
        insideCancelled->objectIntFieldText("value"),
        outsideBeforeCancel->objectIntFieldText("value"),
        outsideAfterCancel->objectIntFieldText("value"),
      )
      ->Expect.expect
      ->Expect.toEqual((
        Some("1"),
        None,
        Some("1"),
        Some("2"),
        None,
        None,
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

  testAsync("relate overloads allow omitted data and array inputs on the installed public SDK surface", async () => {
    let db = Surrealdb_Surreal.make()
    let fromRecord = Surrealdb_RecordId.make("widgets", "a")
    let toRecord = Surrealdb_RecordId.make("widgets", "b")
    let edgeTable = Surrealdb_Table.make("rel")
    try {
      await connectServerDatabase(db)

      let singleNoData =
        db->Surrealdb_Relate.records(fromRecord, edgeTable, toRecord, ())->Surrealdb_Relate.compile
      let singleWithData =
        db
        ->Surrealdb_Relate.records(
            fromRecord,
            edgeTable,
            toRecord,
            ~data=Dict.fromArray([("weight", Surrealdb_JsValue.int(1))]),
            (),
          )
        ->Surrealdb_Relate.compile
      let multiNoData =
        db
        ->Surrealdb_Relate.recordArrays([fromRecord], edgeTable, [toRecord], ())
        ->Surrealdb_Relate.compile

      (
        String.startsWith(singleNoData->Surrealdb_BoundQuery.query, "RELATE  ONLY $bind__"),
        singleNoData->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length,
        singleWithData->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length,
        String.startsWith(multiNoData->Surrealdb_BoundQuery.query, "RELATE  $bind__"),
        multiNoData->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length,
      )
      ->Expect.expect
      ->Expect.toEqual((true, 3, 4, true, 3))

      await closeIgnore(db)
    } catch {
    | error =>
      await closeIgnore(db)
      throw(error)
    }
  })

  testAsync("query and run allow omitted optional arguments on the installed public SDK surface", async () => {
    let db = Surrealdb_Surreal.make()
    try {
      await connectServerDatabase(db)

      let query = db->Surrealdb_Query.text("RETURN 1;", ())
      let awaited = await db->Surrealdb_Query.text("RETURN 1; RETURN 2;", ())->Surrealdb_Query.resolve
      let responses = await query->Surrealdb_Query.responses
      let queryable = db->Surrealdb_Surreal.asQueryable
      let runCompiled = queryable->Surrealdb_Run.callOn("string::len", ())->Surrealdb_Run.compile
      let runJsonCompiled =
        queryable->Surrealdb_Run.callOn("string::len", ())->Surrealdb_Run.json->Surrealdb_Run.compile
      let versionedRunCompiled =
        queryable
        ->Surrealdb_Run.callVersionedOn("string::len", "1.0.0", ())
        ->Surrealdb_Run.compile
      let selectJsonCompiled =
        queryable->Surrealdb_Select.tableOn("widgets")->Surrealdb_Select.json->Surrealdb_Select.compile

      (
        query->Surrealdb_Query.inner->Surrealdb_BoundQuery.query,
        query->Surrealdb_Query.inner->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length,
        awaited->Array.map(Surrealdb_Value.toText),
        responses->Array.length,
        responses->Array.get(0)->Option.map(Surrealdb_QueryResponse.success),
        responses->Array.get(0)->Option.flatMap(Surrealdb_QueryResponse.type_),
        responses->Array.get(0)
        ->Option.flatMap(Surrealdb_QueryResponse.result)
        ->Option.map(Surrealdb_Value.toText),
        runCompiled->Surrealdb_BoundQuery.query,
        runJsonCompiled->Surrealdb_BoundQuery.query,
        versionedRunCompiled->Surrealdb_BoundQuery.query,
        String.startsWith(selectJsonCompiled->Surrealdb_BoundQuery.query, "SELECT * FROM $bind__"),
      )
      ->Expect.expect
      ->Expect.toEqual((
        "RETURN 1;",
        0,
        ["1", "2"],
        1,
        Some(true),
        Some("other"),
        Some("1"),
        "string::len()",
        "string::len()",
        "string::len<1.0.0>()",
        true,
      ))

      await closeIgnore(db)
    } catch {
    | error =>
      await closeIgnore(db)
      throw(error)
    }
  })

  testAsync("streamed error frames expose throw() on the installed public SDK surface", async () => {
    let db = Surrealdb_Surreal.make()
    try {
      await connectServerDatabase(db)

      let frames =
        await db
        ->Surrealdb_Query.text("RETURN 1; THROW 'boom'", ())
        ->Surrealdb_Query.stream
        ->Surrealdb_AsyncIterable.collect

      let errorFrame =
        frames
        ->Array.get(2)
        ->Option.flatMap(Surrealdb_QueryFrame.asError)
        ->Option.getOrThrow

      let thrown =
        try {
          errorFrame->Surrealdb_QueryFrame.throw_
        } catch {
        | JsExn(jsError) =>
          switch jsError->toUnknown->Surrealdb_ServerError.fromUnknown {
          | Some(serverError) => serverError->Surrealdb_ServerError.asSurrealError->Surrealdb_SurrealError.message
          | None => jsError->JsExn.message->Option.getOr("unexpected js error")
          }
        | _ => "unexpected non-js error"
        }

      (
        frames->Array.length,
        frames->Array.get(0)->Option.map(frame => (frame->Surrealdb_QueryFrame.isValue_, frame->Surrealdb_QueryFrame.query)),
        frames->Array.get(1)->Option.map(frame => (frame->Surrealdb_QueryFrame.isDone_, frame->Surrealdb_QueryFrame.query)),
        frames->Array.get(2)->Option.map(frame => (frame->Surrealdb_QueryFrame.isError_, frame->Surrealdb_QueryFrame.query)),
        errorFrame->Surrealdb_QueryFrame.errorValue->Surrealdb_ServerError.kind,
        thrown,
      )
      ->Expect.expect
      ->Expect.toEqual((
        3,
        Some((true, 0)),
        Some((true, 0)),
        Some((true, 1)),
        Surrealdb_ErrorKind.thrown,
        "An error occurred: boom",
      ))

      await closeIgnore(db)
    } catch {
    | error =>
      await closeIgnore(db)
      throw(error)
    }
  })

  testAsync("export allows omitted options on the installed public SDK surface", async () => {
    let db = Surrealdb_Surreal.make()
    try {
      await connectServerDatabase(db)

      let exportSql = await db->Surrealdb_Export.exportSqlDefault->Surrealdb_Export.awaitSql
      let rawResponse =
        await db
        ->Surrealdb_Export.exportSqlDefault
        ->Surrealdb_Export.rawSql
        ->Surrealdb_Export.awaitSql
      (exportSql != "")
      ->Expect.expect
      ->Expect.toBe(true)
      rawResponse->responseStatus->Expect.expect->Expect.toBe(200)

      await closeIgnore(db)
    } catch {
    | error =>
      await closeIgnore(db)
      throw(error)
    }
  })

  testAsync("exportModel surfaces the installed missing-model http error", async () => {
    let db = Surrealdb_Surreal.make()
    try {
      await connectServerDatabase(db)

      let outcome =
        try {
          ignore(await db->Surrealdb_Export.exportModel("missing_model", "1")->Surrealdb_Export.awaitModel)
          "no error"
        } catch {
        | JsExn(jsError) =>
          switch jsError->toUnknown->Surrealdb_ClientError.asHttpConnection {
          | Some(error) => `${error->Surrealdb_ClientError.httpConnectionStatus->Int.toString}:${error->Surrealdb_ClientError.httpConnectionStatusText}`
          | None => jsError->JsExn.message->Option.getOr("unexpected js error")
          }
        | _ => "unexpected non-js error"
        }

      outcome->Expect.expect->Expect.toBe("404:Not Found")

      await closeIgnore(db)
    } catch {
    | error =>
      await closeIgnore(db)
      throw(error)
    }
  })

  testAsync("import accepts blob and readable-stream inputs through the installed public SDK surface", async () => {
    let db = Surrealdb_Surreal.make()
    let tableName = "import_probe"
    let blobId = Surrealdb_RecordId.make(tableName, "blob")
    let streamId = Surrealdb_RecordId.make(tableName, "stream")
    try {
      await connectServerDatabase(db)

      await removeTableIgnore(db, tableName)
      let blob =
        [Webapi.Blob.stringToBlobPart(
          `OPTION IMPORT; DEFINE TABLE ${tableName} SCHEMALESS; CREATE ${tableName}:blob CONTENT { value: 1 };`,
        )]
        ->Webapi.Blob.make
      await db->Surrealdb_Surreal.importBlob(blob)
      let afterBlob =
        await db
        ->Surrealdb_Surreal.asQueryable
        ->Surrealdb_Select.fromRecordIdOn(blobId)
        ->Surrealdb_Select.resolve

      let stream =
        [Webapi.Blob.stringToBlobPart(`OPTION IMPORT; CREATE ${tableName}:stream CONTENT { value: 2 };`)]
        ->Webapi.Blob.make
        ->Webapi.Blob.stream
      await db->Surrealdb_Surreal.importStream(stream)
      let afterStream =
        await db
        ->Surrealdb_Surreal.asQueryable
        ->Surrealdb_Select.fromRecordIdOn(streamId)
        ->Surrealdb_Select.resolve

      (
        afterBlob->objectIntFieldText("value"),
        afterStream->objectIntFieldText("value"),
      )
      ->Expect.expect
      ->Expect.toEqual((Some("1"), Some("2")))

      await removeTableIgnore(db, tableName)
      await closeIgnore(db)
    } catch {
    | error =>
      await removeTableIgnore(db, tableName)
      await closeIgnore(db)
      throw(error)
    }
  })

  testAsync("managed and unmanaged live subscriptions classify on the installed public SDK surface", async () => {
    let db = Surrealdb_Surreal.make()
    let tableName = "widgets"
    let killIgnore = subscription =>
      subscription
      ->Surrealdb_LiveSubscription.kill
      ->Promise.catch(_ => Promise.resolve())

    try {
      await connectServerDatabase(db)
      await removeTableIgnore(db, tableName)
      ignore(await db->Surrealdb_Query.runText(`DEFINE TABLE ${tableName} SCHEMALESS;`))

      let managed =
        await db
        ->Surrealdb_Surreal.asQueryable
        ->Surrealdb_Live.tableNamedOn(tableName)
        ->Surrealdb_Live.awaitManaged
      let queryId =
        switch await db->Surrealdb_Query.text(`LIVE SELECT * FROM ${tableName}`, ())->Surrealdb_Query.resolve {
        | [Uuid(value)] => value
        | [rawValue] =>
          throw(Failure(`LIVE SELECT result did not return a Uuid: ${rawValue->Surrealdb_Value.toText}`))
        | _ => throw(Failure("LIVE SELECT did not return exactly one result"))
        }
      let unmanaged =
        await db
        ->Surrealdb_Surreal.asQueryable
        ->Surrealdb_Live.ofIdOn(queryId)
        ->Surrealdb_Live.awaitUnmanaged

      (
        managed->Surrealdb_ManagedLiveSubscription.fromSubscription->Option.isSome,
        managed->Surrealdb_UnmanagedLiveSubscription.fromSubscription->Option.isSome,
        managed->Surrealdb_LiveSubscription.isManaged,
        unmanaged->Surrealdb_ManagedLiveSubscription.fromSubscription->Option.isSome,
        unmanaged->Surrealdb_UnmanagedLiveSubscription.fromSubscription->Option.isSome,
        unmanaged->Surrealdb_LiveSubscription.isManaged,
      )
      ->Expect.expect
      ->Expect.toEqual((true, false, true, false, true, false))

      let managedMessages = Surrealdb_ChannelIterator.make()
      let unmanagedMessages = Surrealdb_ChannelIterator.make()
      let unsubscribeManaged =
        managed->Surrealdb_LiveSubscription.subscribe(message =>
          managedMessages->Surrealdb_ChannelIterator.submit(message)
        )
      let unsubscribeUnmanaged =
        unmanaged->Surrealdb_LiveSubscription.subscribe(message =>
          unmanagedMessages->Surrealdb_ChannelIterator.submit(message)
        )

      ignore(
        await db
        ->Surrealdb_Surreal.asQueryable
        ->Surrealdb_Create.recordOn(tableName, "alpha")
        ->Surrealdb_Create.content(
            Dict.fromArray([
              ("value", Surrealdb_JsValue.int(2)),
              ("label", Surrealdb_JsValue.string("alpha")),
            ]),
          )
        ->Surrealdb_Create.resolve,
      )

      let managedObserved = await managedMessages->Surrealdb_ChannelIterator.next
      let unmanagedObserved = await unmanagedMessages->Surrealdb_ChannelIterator.next
      unsubscribeManaged()
      unsubscribeUnmanaged()
      managedMessages->Surrealdb_ChannelIterator.cancel
      unmanagedMessages->Surrealdb_ChannelIterator.cancel

      (
        managedObserved->Surrealdb_ChannelIterator.value->Option.map(liveMessageSummary),
        unmanagedObserved->Surrealdb_ChannelIterator.value->Option.map(liveMessageSummary),
      )
      ->Expect.expect
      ->Expect.toEqual((
        Some((
          managed->Surrealdb_LiveSubscription.id->Surrealdb_Uuid.toString,
          "CREATE",
          "widgets:alpha",
          (Some("2"), Some("alpha")),
        )),
        Some((
          unmanaged->Surrealdb_LiveSubscription.id->Surrealdb_Uuid.toString,
          "CREATE",
          "widgets:alpha",
          (Some("2"), Some("alpha")),
        )),
      ))

      await killIgnore(managed)
      await killIgnore(unmanaged)
      await removeTableIgnore(db, tableName)
      await closeIgnore(db)
    } catch {
    | error =>
      await removeTableIgnore(db, tableName)
      await closeIgnore(db)
      throw(error)
    }
  })

  testAsync("session getters and auth compile mirror the installed SDK", async () => {
    let db = Surrealdb_Surreal.make()
    let connectedVersion = ref(None)
    let authTokenSeen = ref(false)
    let usingSelection = ref(None)
    let _offConnected =
      db->Surrealdb_Surreal.subscribe("connected", payload =>
        switch payload {
        | [version] =>
          connectedVersion.contents = Some(version->Surrealdb_Value.toText)
        | _ => ()
        }
      )
    let _offAuth =
      db->Surrealdb_Surreal.subscribe("auth", payload =>
        switch payload {
        | [tokens] =>
          authTokenSeen.contents =
            switch tokens {
            | Object(entries) => entries->Dict.get("access")->Option.isSome
            | _ => false
            }
        | _ => ()
        }
      )
    let _offUsing =
      db->Surrealdb_Surreal.subscribe("using", payload =>
        switch payload {
        | [selection] =>
          usingSelection.contents =
            selection->Surrealdb_Value.toJSON->JSON.stringifyAny
        | _ => ()
        }
      )
    try {
      await connectServerDatabase(db)

      (
        connectedVersion.contents->Option.map(version => String.startsWith(version, "surrealdb-")),
        authTokenSeen.contents,
        usingSelection.contents,
      )
      ->Expect.expect
      ->Expect.toEqual((
        Some(true),
        true,
        expectedUsingSelectionJson(),
      ))

      let rootSession = db->Surrealdb_Surreal.asSession
      (
        rootSession->Surrealdb_Session.namespace,
        rootSession->Surrealdb_Session.database,
        rootSession->Surrealdb_Session.accessToken->Option.isSome,
        rootSession->Surrealdb_Session.isValid,
        rootSession->Surrealdb_Session.sessionId->Option.isSome,
        rootSession->Surrealdb_Session.parameters->Dict.toArray->Array.length,
      )
      ->Expect.expect
      ->Expect.toEqual((
        Some(namespace()),
        Some(database()),
        true,
        true,
        false,
        0,
      ))

      let connectedToken = rootSession->Surrealdb_Session.accessToken

      let rootTokens =
        await rootSession->Surrealdb_Session.signin(
          rootSigninAuth(),
        )
      (rootTokens->Surrealdb_Tokens.access != "")
      ->Expect.expect
      ->Expect.toBe(true)
      rootSession->Surrealdb_Session.accessToken->Expect.expect->Expect.toEqual(
        Some(rootTokens->Surrealdb_Tokens.access),
      )
      (connectedToken != rootSession->Surrealdb_Session.accessToken)
      ->Expect.expect
      ->Expect.toBe(true)

      let authenticatedTokens = await rootSession->Surrealdb_Session.authenticateTokens(rootTokens)
      authenticatedTokens->Surrealdb_Tokens.access->Expect.expect->Expect.toBe(
        rootTokens->Surrealdb_Tokens.access,
      )
      rootSession->Surrealdb_Session.accessToken->Expect.expect->Expect.toEqual(
        Some(authenticatedTokens->Surrealdb_Tokens.access),
      )

      let session = await db->Surrealdb_Surreal.newSession
      let sessionClone =
        switch session->Surrealdb_Session.sessionId {
        | Some(id) => rootSession->Surrealdb_Session.of_(id)
        | None => throw(Failure("expected child session id"))
        }
      (
        sessionClone->Surrealdb_Session.sessionId,
        sessionClone->Surrealdb_Session.isValid,
      )
      ->Expect.expect
      ->Expect.toEqual((session->Surrealdb_Session.sessionId, true))
      (
        session->Surrealdb_Session.namespace,
        session->Surrealdb_Session.database,
        session->Surrealdb_Session.accessToken->Option.isSome,
        session->Surrealdb_Session.isValid,
        session->Surrealdb_Session.sessionId->Option.isSome,
      )
      ->Expect.expect
      ->Expect.toEqual((None, None, false, true, true))

      await (
        session
        ->Surrealdb_Session.useDatabase(namespaceDatabaseSelection())
        ->Promise.then(value => {
          ignore(value)
          Promise.resolve()
        })
      )
      await session->Surrealdb_Session.set("alpha", Surrealdb_JsValue.int(3))
      (
        session->Surrealdb_Session.namespace,
        session->Surrealdb_Session.database,
        session->Surrealdb_Session.parameters->Dict.get("alpha")->Option.isSome,
      )
      ->Expect.expect
      ->Expect.toEqual((Some(namespace()), Some(database()), true))

      await session->Surrealdb_Session.unset("alpha")
      session->Surrealdb_Session.parameters->Dict.get("alpha")->Option.isSome
      ->Expect.expect
      ->Expect.toBe(false)

      db
      ->Surrealdb_Surreal.asQueryable
      ->Surrealdb_Queryable.auth
      ->Surrealdb_Auth.compile
      ->Surrealdb_BoundQuery.query
      ->Expect.expect
      ->Expect.toBe("SELECT * FROM ONLY $auth")

      await rootSession->Surrealdb_Session.invalidate
      rootSession->Surrealdb_Session.accessToken->Expect.expect->Expect.toEqual(None)

      await rootSession->Surrealdb_Session.reset
      (
        rootSession->Surrealdb_Session.namespace,
        rootSession->Surrealdb_Session.database,
        rootSession->Surrealdb_Session.accessToken,
        rootSession->Surrealdb_Session.parameters->Dict.toArray->Array.length,
        rootSession->Surrealdb_Session.isValid,
      )
      ->Expect.expect
      ->Expect.toEqual((None, None, None, 0, true))

      await session->Surrealdb_Session.close
      session->Surrealdb_Session.isValid->Expect.expect->Expect.toBe(false)
      await closeIgnore(db)
    } catch {
    | error =>
      await closeIgnore(db)
      throw(error)
    }
  })
})
