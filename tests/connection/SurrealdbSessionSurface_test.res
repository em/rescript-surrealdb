module Support = SurrealdbSessionTestSupport

let closeIgnore = Support.closeIgnore
let diagnosticPhase = Support.diagnosticPhase
let endpoint = Support.endpoint
let namespace = Support.namespace
let database = Support.database
let rootConnectAuth = Support.rootConnectAuth
let rootAuthentication = Support.rootAuthentication
let rootSigninAuth = Support.rootSigninAuth
let connectServerDatabase = Support.connectServerDatabase
let namespaceDatabaseSelection = Support.namespaceDatabaseSelection
let expectedUsingSelectionJson = Support.expectedUsingSelectionJson
let fileText = Support.fileText

Vitest.describe("SurrealDB session surface", () => {
  Vitest.testAsync("connect options map to the installed public SDK surface", async t => {
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

      t->Vitest.expect((
        db->Surrealdb_Surreal.status,
        db->Surrealdb_Surreal.isConnected,
      ))->Vitest.Expect.toEqual((Surrealdb_ConnectionStatus.Connected, true))

      await closeIgnore(db)
    } catch {
    | error =>
      await closeIgnore(db)
      throw(error)
    }
  })

  Vitest.testAsync("connect auth providers map to the installed public SDK surface", async t => {
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

      t->Vitest.expect((
        db->Surrealdb_Surreal.status,
        db->Surrealdb_Surreal.isConnected,
      ))->Vitest.Expect.toEqual((Surrealdb_ConnectionStatus.Connected, true))

      await closeIgnore(db)
    } catch {
    | error =>
      await closeIgnore(db)
      throw(error)
    }
  })

  Vitest.testAsync("remote engine diagnostics emit the installed connection lifecycle events", async t => {
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

      t->Vitest.expect(phases.contents)->Vitest.Expect.toEqual([
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

  Vitest.testAsync("url-form connect and no-arg use map to the installed public SDK surface", async t => {
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
      t->Vitest.expect((
        selection->Surrealdb_Session.namespaceValue,
        selection->Surrealdb_Session.databaseValue,
      ))->Vitest.Expect.toEqual((Some(namespace()), Some(database())))

      await closeIgnore(db)
    } catch {
    | error =>
      await closeIgnore(db)
      throw(error)
    }
  })

  Vitest.test("health is absent from the unsupported ws/rpc public binding surface", t => {
    let resiTexts = [
      ["src", "connection", "Surrealdb_Surreal.resi"],
      ["src", "connection", "Surrealdb_RpcEngine.resi"],
    ]->Array.map(fileText)

    let jsTexts = [
      ["src", "connection", "Surrealdb_Surreal.mjs"],
      ["src", "connection", "Surrealdb_RpcEngine.mjs"],
    ]->Array.map(fileText)

    t->Vitest.expect((
      resiTexts->Array.every(text => !(text->String.includes("let health:"))),
      jsTexts->Array.every(text => !(text->String.includes("function health("))),
    ))
    ->Vitest.Expect.toEqual((true, true))
  })

  Vitest.testAsync("explicit raw TIMEOUT clauses still work through query text on the supported path", async t => {
    let db = Surrealdb_Surreal.make()
    try {
      await connectServerDatabase(db)

      let timeoutError =
        try {
          ignore(await db->Surrealdb_Query.runText("SELECT VALUE sleep(500ms) FROM ONLY 1 TIMEOUT 50ms;"))
          "no timeout"
        } catch {
        | JsExn(jsError) => jsError->JsExn.message->Option.getOr("unexpected js error")
        | _ => "unexpected non-js error"
        }

      t->Vitest.expect(timeoutError->String.includes("exceeded the timeout"))->Vitest.Expect.toBe(true)

      await closeIgnore(db)
    } catch {
    | error =>
      await closeIgnore(db)
      throw(error)
    }
  })

  Vitest.testAsync("session getters and auth compile mirror the installed SDK", async t => {
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

      t->Vitest.expect((
        connectedVersion.contents->Option.map(version => String.startsWith(version, "surrealdb-")),
        authTokenSeen.contents,
        usingSelection.contents,
      ))->Vitest.Expect.toEqual((
        Some(true),
        true,
        expectedUsingSelectionJson(),
      ))

      let rootSession = db->Surrealdb_Surreal.asSession
      t->Vitest.expect((
        rootSession->Surrealdb_Session.namespace,
        rootSession->Surrealdb_Session.database,
        rootSession->Surrealdb_Session.accessToken->Option.isSome,
        rootSession->Surrealdb_Session.isValid,
        rootSession->Surrealdb_Session.sessionId->Option.isSome,
        rootSession->Surrealdb_Session.parameters->Dict.toArray->Array.length,
      ))->Vitest.Expect.toEqual((
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
      t->Vitest.expect(rootTokens->Surrealdb_Tokens.access != "")->Vitest.Expect.toBe(true)
      t->Vitest.expect(rootSession->Surrealdb_Session.accessToken)->Vitest.Expect.toEqual(
        Some(rootTokens->Surrealdb_Tokens.access),
      )
      t->Vitest.expect(connectedToken != rootSession->Surrealdb_Session.accessToken)->Vitest.Expect.toBe(true)

      let authenticatedTokens = await rootSession->Surrealdb_Session.authenticateTokens(rootTokens)
      t->Vitest.expect(authenticatedTokens->Surrealdb_Tokens.access)->Vitest.Expect.toBe(
        rootTokens->Surrealdb_Tokens.access,
      )
      t->Vitest.expect(rootSession->Surrealdb_Session.accessToken)->Vitest.Expect.toEqual(
        Some(authenticatedTokens->Surrealdb_Tokens.access),
      )

      let session = await db->Surrealdb_Surreal.newSession
      let sessionClone =
        switch session->Surrealdb_Session.sessionId {
        | Some(id) => rootSession->Surrealdb_Session.of_(id)
        | None => throw(Failure("expected child session id"))
        }
      t->Vitest.expect((
        sessionClone->Surrealdb_Session.sessionId,
        sessionClone->Surrealdb_Session.isValid,
      ))->Vitest.Expect.toEqual((session->Surrealdb_Session.sessionId, true))
      t->Vitest.expect((
        session->Surrealdb_Session.namespace,
        session->Surrealdb_Session.database,
        session->Surrealdb_Session.accessToken->Option.isSome,
        session->Surrealdb_Session.isValid,
        session->Surrealdb_Session.sessionId->Option.isSome,
      ))->Vitest.Expect.toEqual((None, None, false, true, true))

      await (
        session
        ->Surrealdb_Session.useDatabase(namespaceDatabaseSelection())
        ->Promise.then(value => {
          ignore(value)
          Promise.resolve()
        })
      )
      await session->Surrealdb_Session.set("alpha", Surrealdb_JsValue.int(3))
      t->Vitest.expect((
        session->Surrealdb_Session.namespace,
        session->Surrealdb_Session.database,
        session->Surrealdb_Session.parameters->Dict.get("alpha")->Option.isSome,
      ))->Vitest.Expect.toEqual((Some(namespace()), Some(database()), true))

      await session->Surrealdb_Session.unset("alpha")
      t->Vitest.expect(session->Surrealdb_Session.parameters->Dict.get("alpha")->Option.isSome)->Vitest.Expect.toBe(false)

      t->Vitest.expect(
        db
        ->Surrealdb_Surreal.asQueryable
        ->Surrealdb_Queryable.auth
        ->Surrealdb_Auth.compile
        ->Surrealdb_BoundQuery.query,
      )->Vitest.Expect.toBe("SELECT * FROM ONLY $auth")

      await rootSession->Surrealdb_Session.invalidate
      t->Vitest.expect(rootSession->Surrealdb_Session.accessToken)->Vitest.Expect.toEqual(None)

      await rootSession->Surrealdb_Session.reset
      t->Vitest.expect((
        rootSession->Surrealdb_Session.namespace,
        rootSession->Surrealdb_Session.database,
        rootSession->Surrealdb_Session.accessToken,
        rootSession->Surrealdb_Session.parameters->Dict.toArray->Array.length,
        rootSession->Surrealdb_Session.isValid,
      ))->Vitest.Expect.toEqual((None, None, None, 0, true))

      await session->Surrealdb_Session.close
      t->Vitest.expect(session->Surrealdb_Session.isValid)->Vitest.Expect.toBe(false)
      await closeIgnore(db)
    } catch {
    | error =>
      await closeIgnore(db)
      throw(error)
    }
  })
})
