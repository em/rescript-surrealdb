let toUnknown = SurrealdbTestCasts.toUnknown
let dictFromUnknown = SurrealdbTestCasts.dictFromUnknown
let jsonFromUnknown = SurrealdbTestCasts.jsonFromUnknown

@obj
external makeRawApiResponse: (
  ~body: Nullable.t<unknown>=?,
  ~headers: Nullable.t<dict<string>>=?,
  ~status: Nullable.t<int>=?,
  unit,
) => Surrealdb_ApiResponse.t = ""

@obj
external makeRawApiJsonResponse: (
  ~body: Nullable.t<JSON.t>=?,
  ~headers: Nullable.t<dict<string>>=?,
  ~status: Nullable.t<int>=?,
  unit,
) => Surrealdb_ApiJsonResponse.t = ""

@obj
external makeRawQueryStats: (
  ~recordsReceived: int,
  ~bytesReceived: int,
  ~recordsScanned: int,
  ~bytesScanned: int,
  ~duration: Surrealdb_Duration.t,
  unit,
) => Surrealdb_QueryStats.t = ""

@obj
external makeRawVersionInfo: (~version: string, unit) => Surrealdb_VersionInfo.t = ""

@obj
external makeRawQueryResponse: (
  ~success: bool,
  ~result: Nullable.t<unknown>=?,
  ~stats: Nullable.t<Surrealdb_QueryStats.t>=?,
  ~error: Nullable.t<Surrealdb_ServerError.t>=?,
  @as("type") ~type_: Nullable.t<string>=?,
  unit,
) => Surrealdb_QueryResponse.t = ""

@module("surrealdb") @new
external makeRawFrame: int => Surrealdb_Frame.t<unknown> = "Frame"

@module("surrealdb") @new
external makeRawValueFrame: (int, unknown, bool) => Surrealdb_Frame.value<unknown> = "ValueFrame"

@module("surrealdb") @new
external makeRawErrorFrame: (
  int,
  Nullable.t<Surrealdb_QueryStats.t>,
  Surrealdb_ServerError.t,
) => Surrealdb_Frame.error<unknown> = "ErrorFrame"

@module("surrealdb") @new
external makeRawDoneFrame: (
  int,
  Nullable.t<Surrealdb_QueryStats.t>,
  string,
) => Surrealdb_Frame.done<unknown> = "DoneFrame"

let jsonText = value =>
  value->JSON.stringifyAny->Option.getOr("")

let hasField = (value, name) =>
  value->toUnknown->dictFromUnknown->Dict.get(name)->Option.isSome

let dictFieldText = (value, name) =>
  value
  ->toUnknown
  ->dictFromUnknown
  ->Dict.get(name)
  ->Option.flatMap(json => json->jsonFromUnknown->JSON.stringifyAny)

let makeDisconnectedDb = () =>
  Surrealdb_RemoteEngines.create()->Surrealdb_Surreal.withRemoteEngines

let makeStats = () =>
  makeRawQueryStats(
    ~recordsReceived=1,
    ~bytesReceived=2,
    ~recordsScanned=3,
    ~bytesScanned=4,
    ~duration=Surrealdb_Duration.fromString("5ms"),
    (),
  )

let makeServerError = () =>
  Surrealdb_ServerError.makeRpcErrorObject(
    ~code=-32000,
    ~message="Synthetic timeout",
    ~kind=Surrealdb_ErrorKind.query,
    (),
  )->Surrealdb_ServerError.parseRpcError
