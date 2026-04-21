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

let subscribe: (t, string, array<unknown> => unit) => unit => unit
let makeDefault: unit => t
let driverOptions: (
  ~engines: Surrealdb_RemoteEngines.t=?,
  ~codecs: dict<Surrealdb_ValueCodec.factory>=?,
  ~codecOptions: Surrealdb_CborCodec.options=?,
  ~websocketImpl: websocketImpl=?,
  ~fetchImpl: fetchImpl=?,
  unit,
) => driverOptions
let makeWithOptions: driverOptions => t
let asQueryable: t => Surrealdb_Queryable.t
let asSession: t => Surrealdb_Session.t
let makeConnectOptions: (
  ~namespace: string=?,
  ~database: string=?,
  ~authentication: authentication=?,
  ~versionCheck: bool=?,
  ~invalidateOnExpiry: bool=?,
  ~reconnect: reconnect=?,
  unit,
) => connectOptions
let makeReconnectOptionsRaw: (
  ~enabled: bool=?,
  ~attempts: int=?,
  ~retryDelay: int=?,
  ~retryDelayMax: int=?,
  ~retryDelayMultiplier: float=?,
  ~retryDelayJitter: float=?,
  ~catchError: (JsExn.t => bool)=?,
  unit,
) => reconnectOptions
let rootConnectAuth: (~username: string, ~password: string, unit) => connectAuth
let namespaceConnectAuth: (~namespace: string, ~username: string, ~password: string, unit) => connectAuth
let databaseConnectAuth: (
  ~namespace: string,
  ~database: string,
  ~username: string,
  ~password: string,
  unit,
) => connectAuth
let tokenConnectAuth: string => connectAuth
let providedAuthFromConnectAuth: connectAuth => providedAuth
let staticAuthenticationRaw: providedAuth => authentication
let syncAuthenticationProviderRaw: (Nullable.t<Surrealdb_Uuid.t> => providedAuth) => authentication
let asyncAuthenticationProviderRaw: (
  Nullable.t<Surrealdb_Uuid.t> => promise<providedAuth>
) => authentication
let reconnectFromBool: bool => reconnect
let reconnectFromOptions: reconnectOptions => reconnect
let importStringInput: string => importInput
let importBlobInput: Webapi.Blob.t => importInput
let importStreamInput: Webapi.ReadableStream.t => importInput
let nullProvidedAuth: providedAuth
let defaultWebSocketImpl: websocketImpl
let defaultFetchImpl: fetchImpl
let connectRaw: (t, string, connectOptions) => promise<bool>
let connectUrlRaw: (t, Webapi.Url.t, connectOptions) => promise<bool>
let isConnected: t => bool
let status: t => string
let ready: t => promise<unit>
let close: t => promise<bool>
let closeSession: t => promise<unit>
let health: t => promise<unit>
let version: t => promise<Surrealdb_VersionInfo.t>
let sessions: t => promise<array<Surrealdb_Uuid.t>>
let newSession: t => promise<Surrealdb_Session.t>
let beginTransaction: t => promise<Surrealdb_Transaction.t>
let importRaw: (t, importInput) => promise<unit>
let isFeatureSupported: (t, Surrealdb_Feature.t) => bool
let make: unit => t
let withOptions: (
  ~engines: Surrealdb_RemoteEngines.t=?,
  ~codecs: dict<Surrealdb_ValueCodec.factory>=?,
  ~codecOptions: Surrealdb_CborCodec.options=?,
  ~websocketImpl: websocketImpl=?,
  ~fetchImpl: fetchImpl=?,
  unit,
) => t
let withRemoteEngines: Surrealdb_RemoteEngines.t => t
let makeReconnect: (
  ~enabled: bool=?,
  ~attempts: int=?,
  ~retryDelay: int=?,
  ~retryDelayMax: int=?,
  ~retryDelayMultiplier: float=?,
  ~retryDelayJitter: float=?,
  ~catchError: (JsExn.t => bool)=?,
  unit,
) => reconnect
let reconnectEnabled: bool => reconnect
let staticAuthentication: connectAuth => authentication
let noAuthentication: unit => authentication
let syncAuthenticationProvider: (Nullable.t<Surrealdb_Uuid.t> => providedAuth) => authentication
let asyncAuthenticationProvider: (
  Nullable.t<Surrealdb_Uuid.t> => promise<providedAuth>
) => authentication
let connect: (
  t,
  string,
  ~namespace: string=?,
  ~database: string=?,
  ~authentication: authentication=?,
  ~versionCheck: bool=?,
  ~invalidateOnExpiry: bool=?,
  ~reconnect: reconnect=?,
  unit,
) => promise<unit>
let connectUrl: (
  t,
  Webapi.Url.t,
  ~namespace: string=?,
  ~database: string=?,
  ~authentication: authentication=?,
  ~versionCheck: bool=?,
  ~invalidateOnExpiry: bool=?,
  ~reconnect: reconnect=?,
  unit,
) => promise<unit>
let connectDatabase: (t, string, string, string) => promise<unit>
let connectServerDatabase: (t, string, string, string, string, string) => promise<unit>
let importText: (t, string) => promise<unit>
let importBlob: (t, Webapi.Blob.t) => promise<unit>
let importStream: (t, Webapi.ReadableStream.t) => promise<unit>
