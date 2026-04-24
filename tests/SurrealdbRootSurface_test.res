module Support = SurrealdbCoverageTestSupport

let makeDisconnectedDb = Support.makeDisconnectedDb
let hasField = Support.hasField
let dictFieldText = Support.dictFieldText
let toUnknown = SurrealdbTestCasts.toUnknown
let dictFromUnknown = SurrealdbTestCasts.dictFromUnknown

Vitest.describe("SurrealDB root surface", () => {
  Vitest.test("root namespace exports resolve through the public Surrealdb module", t => {
    let db = makeDisconnectedDb()
    let rootSelectCompiled = Surrealdb.Query.Select.table(db, "widgets")->Surrealdb.Query.Select.compile
    let rootToken = Surrealdb.Support.Tokens.make(~access="root-access", ~refresh="root-refresh", ())
    let rootTable = Surrealdb.Values.Table.make("widgets")

    t->Vitest.expect((
      rootSelectCompiled->Surrealdb_BoundQuery.query->String.startsWith("SELECT * FROM $bind__"),
      rootToken->Surrealdb.Support.Tokens.access,
      rootToken->Surrealdb.Support.Tokens.refresh,
      rootTable->Surrealdb.Values.Table.name,
      Surrealdb.Connection.Features.liveQueries->Surrealdb.Connection.Feature.name,
      Surrealdb.Query.Output.After->Surrealdb.Query.Output.toString,
      Surrealdb.Live.Actions.values()->Array.map(Surrealdb.Live.Actions.toString),
    ))->Vitest.Expect.toEqual((
      true,
      "root-access",
      Some("root-refresh"),
      "widgets",
      "live-queries",
      "after",
      ["CREATE", "UPDATE", "DELETE", "KILLED"],
    ))
  })

  Vitest.test("client and session builders keep the public contract explicit", t => {
    let db = makeDisconnectedDb()
    let engines = Surrealdb_RemoteEngines.create()
    let codecFactories = Dict.fromArray([("cbor", Surrealdb_ValueCodec.cborFactory)])
    let codecOptions = Surrealdb_CborCodec.makeOptions(~useNativeDates=true, ())
    let driverOptions =
      Surrealdb_Surreal.driverOptions(
        ~engines,
        ~codecs=codecFactories,
        ~codecOptions,
        ~fetchImpl=Surrealdb_Surreal.defaultFetchImpl,
        (),
      )
    let reconnectOptions =
      Surrealdb_Surreal.makeReconnectOptionsRaw(
        ~enabled=true,
        ~attempts=3,
        ~retryDelay=100,
        ~retryDelayMax=500,
        ~retryDelayMultiplier=2.0,
        ~retryDelayJitter=0.25,
        ~catchError=_ => true,
        (),
      )
    let reconnect = reconnectOptions->Surrealdb_Surreal.reconnectFromOptions
    let rootAuth = Surrealdb_Surreal.rootConnectAuth(~username="root", ~password="root", ())
    let namespaceAuth =
      Surrealdb_Surreal.namespaceConnectAuth(
        ~namespace="test_ns",
        ~username="root",
        ~password="root",
        (),
      )
    let databaseAuth =
      Surrealdb_Surreal.databaseConnectAuth(
        ~namespace="test_ns",
        ~database="test_db",
        ~username="root",
        ~password="root",
        (),
      )
    let tokenAuth = Surrealdb_Surreal.tokenConnectAuth("jwt-token")
    let connectOptions =
      Surrealdb_Surreal.makeConnectOptions(
        ~namespace="test_ns",
        ~database="test_db",
        ~authentication=rootAuth->Surrealdb_Surreal.staticAuthentication,
        ~versionCheck=false,
        ~invalidateOnExpiry=true,
        ~reconnect,
        (),
      )
    let connectOptionsWithToken =
      Surrealdb_Surreal.makeConnectOptions(
        ~authentication=tokenAuth
        ->Surrealdb_Surreal.providedAuthFromConnectAuth
        ->Surrealdb_Surreal.staticAuthenticationRaw,
        (),
      )
    let connectOptionsNoAuth =
      Surrealdb_Surreal.makeConnectOptions(~authentication=Surrealdb_Surreal.noAuthentication(), ())
    let connectOptionsSync =
      Surrealdb_Surreal.makeConnectOptions(
        ~authentication=Surrealdb_Surreal.syncAuthenticationProvider(_ => {
          rootAuth->Surrealdb_Surreal.providedAuthFromConnectAuth
        }),
        (),
      )
    let connectOptionsAsync =
      Surrealdb_Surreal.makeConnectOptions(
        ~authentication=Surrealdb_Surreal.asyncAuthenticationProvider(_ =>
          Promise.resolve(rootAuth->Surrealdb_Surreal.providedAuthFromConnectAuth)
        ),
        (),
      )
    let rootSignin = Surrealdb_Session.rootAuth(~username="root", ~password="root", ())
    let namespaceSignin =
      Surrealdb_Session.namespaceAuth(
        ~namespace="test_ns",
        ~username="root",
        ~password="root",
        (),
      )
    let databaseSignin =
      Surrealdb_Session.databaseAuth(
        ~namespace="test_ns",
        ~database="test_db",
        ~username="root",
        ~password="root",
        (),
      )
    let accessSystemSignin =
      Surrealdb_Session.accessSystemAuth(
        ~username="root",
        ~password="root",
        ~access="admin",
        ~namespace="test_ns",
        ~database="test_db",
        (),
      )
    let accessBearerSignin =
      Surrealdb_Session.accessBearerAuth(
        ~access="admin",
        ~key="secret",
        ~namespace="test_ns",
        ~database="test_db",
        (),
      )
    let accessRecord =
      Surrealdb_Session.makeAccessRecordAuth(
        ~access="record_access",
        ~variables=Dict.fromArray([("slug", Surrealdb_JsValue.string("alpha"))]),
        ~namespace="test_ns",
        ~database="test_db",
        (),
      )
    let namespaceDatabase =
      Surrealdb_Session.makeNamespaceDatabase(
        ~namespace=Nullable.make("test_ns"),
        ~database=Nullable.make("test_db"),
        (),
      )
    let stream =
      [Webapi.Blob.stringToBlobPart("RETURN 1;")]->Webapi.Blob.make->Webapi.Blob.stream
    let disconnectedWithOptions =
      Surrealdb_Surreal.withOptions(
        ~engines,
        ~codecs=codecFactories,
        ~codecOptions,
        ~fetchImpl=Surrealdb_Surreal.defaultFetchImpl,
        (),
      )

    t->Vitest.expect((
      driverOptions->hasField("engines"),
      driverOptions->hasField("codecs"),
      driverOptions->hasField("codecOptions"),
      reconnectOptions->hasField("catch"),
      reconnect->toUnknown !== db->toUnknown,
      connectOptions->hasField("namespace"),
      connectOptions->hasField("database"),
      connectOptions->hasField("authentication"),
      connectOptions->hasField("reconnect"),
      connectOptionsWithToken->hasField("authentication"),
      connectOptionsNoAuth->hasField("authentication"),
      connectOptionsSync->hasField("authentication"),
      connectOptionsAsync->hasField("authentication"),
      rootAuth->dictFieldText("username"),
      namespaceAuth->dictFieldText("namespace"),
      databaseAuth->dictFieldText("database"),
      tokenAuth->toUnknown == "jwt-token"->toUnknown,
      rootSignin->dictFieldText("username"),
      namespaceSignin->dictFieldText("namespace"),
      databaseSignin->dictFieldText("database"),
      accessSystemSignin->dictFieldText("access"),
      accessBearerSignin->dictFieldText("access"),
      accessRecord->Surrealdb_Session.accessRecordAsSignin->toUnknown->dictFromUnknown->Dict.get("variables")->Option.isSome,
      namespaceDatabase->Surrealdb_Session.namespaceValue,
      namespaceDatabase->Surrealdb_Session.databaseValue,
      Surrealdb_Surreal.reconnectEnabled(true)->toUnknown !== reconnect->toUnknown,
      "seed"->Surrealdb_Surreal.importStringInput->toUnknown == "seed"->toUnknown,
      stream->Surrealdb_Surreal.importStreamInput->toUnknown == stream->toUnknown,
      disconnectedWithOptions->Surrealdb_Surreal.status,
      disconnectedWithOptions->Surrealdb_Surreal.isConnected,
      disconnectedWithOptions->Surrealdb_Surreal.asQueryable->toUnknown == disconnectedWithOptions->toUnknown,
      disconnectedWithOptions->Surrealdb_Surreal.asSession->toUnknown == disconnectedWithOptions->toUnknown,
      Surrealdb_Surreal.defaultWebSocketImpl->Option.isSome,
    ))->Vitest.Expect.toEqual((
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      Some("\"root\""),
      Some("\"test_ns\""),
      Some("\"test_db\""),
      true,
      Some("\"root\""),
      Some("\"test_ns\""),
      Some("\"test_db\""),
      Some("\"admin\""),
      Some("\"admin\""),
      true,
      Some("test_ns"),
      Some("test_db"),
      true,
      true,
      true,
      Surrealdb_ConnectionStatus.Disconnected,
      false,
      true,
      true,
      true,
    ))
  })

})
