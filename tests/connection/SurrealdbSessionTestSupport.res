@obj
external makeRawApiResponse: (
  ~body: Nullable.t<unknown>=?,
  ~headers: Nullable.t<dict<string>>=?,
  ~status: Nullable.t<int>=?,
  unit,
) => Surrealdb_ApiResponse.t = ""
@get external responseStatus: Webapi.Fetch.Response.t => int = "status"

let toUnknown = SurrealdbTestCasts.toUnknown

let cwd = () => NodeJs.Process.process->NodeJs.Process.cwd

let fileText = parts =>
  NodeJs.Path.join([cwd(), ...parts])->NodeJs.Fs.readFileSync->NodeJs.Buffer.toString

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
    message->Surrealdb_LiveMessage.action->Surrealdb_LiveActions.toString,
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
