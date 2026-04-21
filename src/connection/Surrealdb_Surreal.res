// src/bindings/Surrealdb_Surreal.res — SurrealDB client binding.
// Concern: bind the Surreal client class and its connection/auth lifecycle.
// Source: node_modules/surrealdb/dist/surrealdb.d.ts — Surreal extends
// SurrealSession, exposes connect(), signin(), sessions(), newSession(),
// beginTransaction(), isConnected, and close().
type t
type driverOptions
type connectAuth
type providedAuth
type authentication
type connectOptions
type reconnect
type reconnectOptions
type websocketImpl
type fetchImpl
type importInput

@module("../support/Surrealdb_Interop.js")
external subscribe: (t, string, array<unknown> => unit) => unit => unit = "subscribeEvent"

@module("surrealdb") @new
external makeDefault: unit => t = "Surreal"

@obj
external driverOptions: (
  ~engines: Surrealdb_RemoteEngines.t=?,
  ~codecs: dict<Surrealdb_ValueCodec.factory>=?,
  ~codecOptions: Surrealdb_CborCodec.options=?,
  ~websocketImpl: websocketImpl=?,
  ~fetchImpl: fetchImpl=?,
  unit,
) => driverOptions = ""

@module("surrealdb") @new
external makeWithOptions: driverOptions => t = "Surreal"

external asQueryable: t => Surrealdb_Queryable.t = "%identity"
external asSession: t => Surrealdb_Session.t = "%identity"

@obj
external makeConnectOptions: (
  ~namespace: string=?,
  ~database: string=?,
  ~authentication: authentication=?,
  ~versionCheck: bool=?,
  ~invalidateOnExpiry: bool=?,
  ~reconnect: reconnect=?,
  unit,
) => connectOptions = ""

@obj
external makeReconnectOptionsRaw: (
  ~enabled: bool=?,
  ~attempts: int=?,
  ~retryDelay: int=?,
  ~retryDelayMax: int=?,
  ~retryDelayMultiplier: float=?,
  ~retryDelayJitter: float=?,
  @as("catch") ~catchError: (JsExn.t => bool)=?,
  unit,
) => reconnectOptions = ""

@obj
external rootConnectAuth: (
  ~username: string,
  ~password: string,
  unit,
) => connectAuth = ""

@obj
external namespaceConnectAuth: (
  ~namespace: string,
  ~username: string,
  ~password: string,
  unit,
) => connectAuth = ""

@obj
external databaseConnectAuth: (
  ~namespace: string,
  ~database: string,
  ~username: string,
  ~password: string,
  unit,
) => connectAuth = ""

external tokenConnectAuth: string => connectAuth = "%identity"
external providedAuthFromConnectAuth: connectAuth => providedAuth = "%identity"
external staticAuthenticationRaw: providedAuth => authentication = "%identity"
external syncAuthenticationProviderRaw: (Nullable.t<Surrealdb_Uuid.t> => providedAuth) => authentication = "%identity"
external asyncAuthenticationProviderRaw: (Nullable.t<Surrealdb_Uuid.t> => promise<providedAuth>) => authentication = "%identity"
external reconnectFromBool: bool => reconnect = "%identity"
external reconnectFromOptions: reconnectOptions => reconnect = "%identity"
external importStringInput: string => importInput = "%identity"
external importBlobInput: Webapi.Blob.t => importInput = "%identity"
external importStreamInput: Webapi.ReadableStream.t => importInput = "%identity"

@module("../support/Surrealdb_Interop.js") @val external nullProvidedAuth: providedAuth = "nullValue"

@val external defaultWebSocketImpl: websocketImpl = "WebSocket"
@val external defaultFetchImpl: fetchImpl = "fetch"

@send
external connectRaw: (t, string, connectOptions) => promise<bool> = "connect"

@send
external connectUrlRaw: (t, Webapi.Url.t, connectOptions) => promise<bool> = "connect"

@get
external isConnected: t => bool = "isConnected"

@get external status: t => string = "status"
@get external ready: t => promise<unit> = "ready"

@send
external close: t => promise<bool> = "close"

@send external closeSession: t => promise<unit> = "closeSession"

@send external health: t => promise<unit> = "health"
@send external version: t => promise<Surrealdb_VersionInfo.t> = "version"
@send external sessions: t => promise<array<Surrealdb_Uuid.t>> = "sessions"
@send external newSession: t => promise<Surrealdb_Session.t> = "newSession"
@send external beginTransaction: t => promise<Surrealdb_Transaction.t> = "beginTransaction"
@send external importRaw: (t, importInput) => promise<unit> = "import"
@send external isFeatureSupported: (t, Surrealdb_Feature.t) => bool = "isFeatureSupported"

let make = () => makeDefault()

let withOptions = (~engines=?, ~codecs=?, ~codecOptions=?, ~websocketImpl=?, ~fetchImpl=?, ()) =>
  makeWithOptions(
    driverOptions(~engines?, ~codecs?, ~codecOptions?, ~websocketImpl?, ~fetchImpl?, ()),
  )

let withRemoteEngines = engines =>
  withOptions(~engines, ())

let makeReconnect = (
  ~enabled=?,
  ~attempts=?,
  ~retryDelay=?,
  ~retryDelayMax=?,
  ~retryDelayMultiplier=?,
  ~retryDelayJitter=?,
  ~catchError=?,
  (),
) =>
  reconnectFromOptions(
    makeReconnectOptionsRaw(
      ~enabled?,
      ~attempts?,
      ~retryDelay?,
      ~retryDelayMax?,
      ~retryDelayMultiplier?,
      ~retryDelayJitter?,
      ~catchError?,
      (),
    ),
  )

let reconnectEnabled = enabled =>
  reconnectFromBool(enabled)

let staticAuthentication = auth =>
  auth->providedAuthFromConnectAuth->staticAuthenticationRaw

let noAuthentication = () =>
  nullProvidedAuth->staticAuthenticationRaw

let syncAuthenticationProvider = provider =>
  syncAuthenticationProviderRaw(provider)

let asyncAuthenticationProvider = provider =>
  asyncAuthenticationProviderRaw(provider)

let connect = (
  db,
  endpoint,
  ~namespace=?,
  ~database=?,
  ~authentication=?,
  ~versionCheck=?,
  ~invalidateOnExpiry=?,
  ~reconnect=?,
  (),
) =>
  db
  ->connectRaw(
      endpoint,
      makeConnectOptions(
        ~namespace?,
        ~database?,
        ~authentication?,
        ~versionCheck?,
        ~invalidateOnExpiry?,
        ~reconnect?,
        (),
      ),
    )
  ->Promise.then(_ => Promise.resolve())

let connectUrl = (
  db,
  endpoint,
  ~namespace=?,
  ~database=?,
  ~authentication=?,
  ~versionCheck=?,
  ~invalidateOnExpiry=?,
  ~reconnect=?,
  (),
) =>
  db
  ->connectUrlRaw(
      endpoint,
      makeConnectOptions(
        ~namespace?,
        ~database?,
        ~authentication?,
        ~versionCheck?,
        ~invalidateOnExpiry?,
        ~reconnect?,
        (),
      ),
    )
  ->Promise.then(_ => Promise.resolve())

let connectDatabase = (db, endpoint, namespace, database) =>
  connect(db, endpoint, ~namespace, ~database, ())

let connectServerDatabase = (db, endpoint, namespace, database, username, password) =>
  connect(
    db,
    endpoint,
    ~namespace,
    ~database,
    ~authentication=staticAuthentication(rootConnectAuth(~username, ~password, ())),
    (),
  )

let importText = (db, text) =>
  db->importRaw(text->importStringInput)

let importBlob = (db, blob) =>
  db->importRaw(blob->importBlobInput)

let importStream = (db, stream) =>
  db->importRaw(stream->importStreamInput)
