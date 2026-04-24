module CoverageSupport = SurrealdbCoverageTestSupport

let toUnknown = SurrealdbTestCasts.toUnknown
let stringToUnknown = SurrealdbTestCasts.stringToUnknown
let dictToUnknown = SurrealdbTestCasts.dictToUnknown

@module("surrealdb") @new external makeCallTerminatedError: unit => Surrealdb_SurrealError.t = "CallTerminatedError"
@module("surrealdb") @new external makeReconnectExhaustionError: unit => Surrealdb_SurrealError.t = "ReconnectExhaustionError"
@module("surrealdb") @new external makeReconnectIterationError: unit => Surrealdb_SurrealError.t = "ReconnectIterationError"
@module("surrealdb") @new external makeUnsupportedEngineError: string => Surrealdb_SurrealError.t = "UnsupportedEngineError"
@module("surrealdb") @new external makeConnectionUnavailableError: unit => Surrealdb_SurrealError.t = "ConnectionUnavailableError"
@module("surrealdb") @new external makeMissingNamespaceDatabaseError: unit => Surrealdb_SurrealError.t = "MissingNamespaceDatabaseError"
@module("surrealdb") @new external makeHttpConnectionError: (
  string,
  int,
  string,
  ArrayBuffer.t,
) => Surrealdb_SurrealError.t = "HttpConnectionError"
@module("surrealdb") @new external makeAuthenticationError: unknown => Surrealdb_SurrealError.t = "AuthenticationError"
@module("surrealdb") @new external makeLiveSubscriptionError: string => Surrealdb_SurrealError.t = "LiveSubscriptionError"
@module("surrealdb") @new external makeUnsupportedVersionError: (
  string,
  string,
  string,
) => Surrealdb_SurrealError.t = "UnsupportedVersionError"
@module("surrealdb") @new external makeExpressionError: string => Surrealdb_SurrealError.t = "ExpressionError"
@module("surrealdb") @new external makeUnavailableFeatureError: (
  Surrealdb_Feature.t,
  string,
) => Surrealdb_SurrealError.t = "UnavailableFeatureError"
@module("surrealdb") @new external makeInvalidSessionError: (
  Nullable.t<Surrealdb_Uuid.t>,
) => Surrealdb_SurrealError.t = "InvalidSessionError"
@module("surrealdb") @new external makeUnsuccessfulApiError: (
  string,
  string,
  Surrealdb_ApiResponse.t,
) => Surrealdb_SurrealError.t = "UnsuccessfulApiError"
@module("surrealdb") @new external makeInvalidDateError: string => Surrealdb_SurrealError.t = "InvalidDateError"
@module("surrealdb") @new external makeInvalidRecordIdError: unit => Surrealdb_SurrealError.t = "InvalidRecordIdError"
@module("surrealdb") @new external makeInvalidDurationError: unit => Surrealdb_SurrealError.t = "InvalidDurationError"
@module("surrealdb") @new external makeInvalidDecimalError: unit => Surrealdb_SurrealError.t = "InvalidDecimalError"
@module("surrealdb") @new external makeInvalidTableError: unit => Surrealdb_SurrealError.t = "InvalidTableError"
@new external makeArrayBuffer: int => ArrayBuffer.t = "ArrayBuffer"

let makeDetail = (~kind, ~details=?, ()) => {
  let payload = Dict.fromArray([("kind", kind->stringToUnknown)])
  switch details {
  | Some(value) => Dict.fromArray([("kind", kind->stringToUnknown), ("details", value->dictToUnknown)])
  | None => payload
  }
}

let stringField = (entries, key) =>
  switch entries->Dict.get(key) {
  | Some(value) => value->JSON.Decode.string
  | None => None
  }

let boolField = (entries, key) =>
  switch entries->Dict.get(key) {
  | Some(value) => value->JSON.Decode.bool
  | None => None
  }

let jsonFieldText = (entries, key) =>
  switch entries->Dict.get(key) {
  | Some(value) => value->JSON.stringifyAny
  | None => None
  }

let objectField = (entries, key) =>
  switch entries->Dict.get(key) {
  | Some(value) => value->JSON.Decode.object
  | None => None
  }

let jsonObject = value =>
  value->JSON.Decode.object->Option.getOr(Dict.make())

Vitest.describe("SurrealDB error hierarchy coverage", () => {
  Vitest.test("client error subclasses classify and serialize through the public surface", t => {
    let buffer = makeArrayBuffer(4)
    let unavailableFeature =
      makeUnavailableFeatureError(Surrealdb_Features.liveQueries, "2.3.1")
    let invalidSession =
      makeInvalidSessionError(Nullable.make(Surrealdb_Uuid.fromString("018cc251-4f5c-7def-b4c6-000000000001")))
    let unsuccessfulApi =
      makeUnsuccessfulApiError(
        "/api/widgets",
        "post",
        CoverageSupport.makeRawApiResponse(~status=Nullable.make(418), ~body=Nullable.null, ()),
      )

    t->Vitest.expect((
      makeCallTerminatedError()->toUnknown->Surrealdb_ClientError.asCallTerminated->Option.isSome,
      makeReconnectExhaustionError()->toUnknown->Surrealdb_ClientError.asReconnectExhaustion->Option.isSome,
      makeReconnectIterationError()->toUnknown->Surrealdb_ClientError.asReconnectIteration->Option.isSome,
      makeUnsupportedEngineError("ftp")->toUnknown->Surrealdb_ClientError.asUnsupportedEngine->Option.map(Surrealdb_ClientError.unsupportedEngineName),
      makeConnectionUnavailableError()->toUnknown->Surrealdb_ClientError.asConnectionUnavailable->Option.isSome,
      makeMissingNamespaceDatabaseError()->toUnknown->Surrealdb_ClientError.asMissingNamespaceDatabase->Option.isSome,
      makeHttpConnectionError("failed", 503, "unavailable", buffer)
      ->toUnknown
      ->Surrealdb_ClientError.asHttpConnection
      ->Option.map(value => (
          value->Surrealdb_ClientError.httpConnectionStatus,
          value->Surrealdb_ClientError.httpConnectionStatusText,
          value->Surrealdb_ClientError.httpConnectionBuffer->Surrealdb_ClientError.arrayBufferByteLength,
        )),
      makeAuthenticationError(stringToUnknown("bad token"))->toUnknown->Surrealdb_ClientError.asAuthentication->Option.isSome,
      makeLiveSubscriptionError("offline")->toUnknown->Surrealdb_ClientError.asLiveSubscription->Option.isSome,
      makeUnsupportedVersionError("2.0.0", "2.1.0", "4.0.0")
      ->toUnknown
      ->Surrealdb_ClientError.asUnsupportedVersion
      ->Option.map(value => (
          value->Surrealdb_ClientError.unsupportedVersionVersion,
          value->Surrealdb_ClientError.unsupportedVersionMinimum,
          value->Surrealdb_ClientError.unsupportedVersionMaximum,
        )),
      makeExpressionError("bad expression")->toUnknown->Surrealdb_ClientError.asExpression->Option.isSome,
      unavailableFeature
      ->toUnknown
      ->Surrealdb_ClientError.asUnavailableFeature
      ->Option.map(value => (
          value->Surrealdb_ClientError.unavailableFeatureValue,
          value->Surrealdb_ClientError.unavailableFeatureVersion,
        )),
      invalidSession
      ->toUnknown
      ->Surrealdb_ClientError.asInvalidSession
      ->Option.map(value => value->Surrealdb_ClientError.invalidSession->Option.map(Surrealdb_Uuid.toString)),
      unsuccessfulApi
      ->toUnknown
      ->Surrealdb_ClientError.asUnsuccessfulApi
      ->Option.map(value => (
          value->Surrealdb_ClientError.unsuccessfulApiPath,
          value->Surrealdb_ClientError.unsuccessfulApiMethod,
          value->Surrealdb_ClientError.unsuccessfulApiResponse->Surrealdb_ApiResponse.status,
        )),
      makeInvalidDateError("invalid date")->toUnknown->Surrealdb_ClientError.asInvalidDate->Option.isSome,
      makeInvalidRecordIdError()->toUnknown->Surrealdb_ClientError.asInvalidRecordId->Option.isSome,
      makeInvalidDurationError()->toUnknown->Surrealdb_ClientError.asInvalidDuration->Option.isSome,
      makeInvalidDecimalError()->toUnknown->Surrealdb_ClientError.asInvalidDecimal->Option.isSome,
      makeInvalidTableError()->toUnknown->Surrealdb_ClientError.asInvalidTable->Option.isSome,
    ))->Vitest.Expect.toEqual((
      true,
      true,
      true,
      Some("ftp"),
      true,
      true,
      Some((503, "unavailable", 4)),
      true,
      true,
      Some(("2.0.0", "2.1.0", "4.0.0")),
      true,
      Some((Surrealdb_ClientError.Feature(Surrealdb_Features.liveQueries), "2.3.1")),
      Some(Some("018cc251-4f5c-7def-b4c6-000000000001")),
      Some(("/api/widgets", "post", Some(418))),
      true,
      true,
      true,
      true,
      true,
    ))

    let payload =
      unavailableFeature
      ->Surrealdb_ClientError.toJSON
      ->jsonObject
    t->Vitest.expect((
      payload->stringField("sdkClass"),
      payload->stringField("version"),
      payload->objectField("feature")->Option.flatMap(feature => feature->stringField("name")),
    ))->Vitest.Expect.toEqual((
      Some("UnavailableFeatureError"),
      Some("2.3.1"),
      Some("live-queries"),
    ))

    let clientJsonSummaries = [
      makeCallTerminatedError(),
      makeReconnectExhaustionError(),
      makeReconnectIterationError(),
      makeUnsupportedEngineError("ftp"),
      makeConnectionUnavailableError(),
      makeMissingNamespaceDatabaseError(),
      makeHttpConnectionError("failed", 503, "unavailable", buffer),
      makeAuthenticationError(stringToUnknown("bad token")),
      makeLiveSubscriptionError("offline"),
      makeUnsupportedVersionError("2.0.0", "2.1.0", "4.0.0"),
      makeExpressionError("bad expression"),
      makeInvalidDateError("invalid date"),
      makeInvalidRecordIdError(),
      makeInvalidDurationError(),
      makeInvalidDecimalError(),
      makeInvalidTableError(),
      unavailableFeature,
      invalidSession,
      unsuccessfulApi,
    ]
    ->Array.map(error => {
        let payload = error->Surrealdb_ClientError.toJSON->jsonObject
        (
          payload->stringField("sdkClass"),
          payload->stringField("engine"),
          payload->jsonFieldText("status"),
          payload->jsonFieldText("bufferByteLength"),
          payload->stringField("version"),
          payload->jsonFieldText("session"),
          payload->stringField("path"),
        )
      })

    t->Vitest.expect(clientJsonSummaries)->Vitest.Expect.toEqual([
      (Some("CallTerminatedError"), None, None, None, None, None, None),
      (Some("ReconnectExhaustionError"), None, None, None, None, None, None),
      (Some("ReconnectIterationError"), None, None, None, None, None, None),
      (Some("UnsupportedEngineError"), Some("ftp"), None, None, None, None, None),
      (Some("ConnectionUnavailableError"), None, None, None, None, None, None),
      (Some("MissingNamespaceDatabaseError"), None, None, None, None, None, None),
      (Some("HttpConnectionError"), None, Some("503"), Some("4"), None, None, None),
      (Some("AuthenticationError"), None, None, None, None, None, None),
      (Some("LiveSubscriptionError"), None, None, None, None, None, None),
      (Some("UnsupportedVersionError"), None, None, None, Some("2.0.0"), None, None),
      (Some("ExpressionError"), None, None, None, None, None, None),
      (Some("InvalidDateError"), None, None, None, None, None, None),
      (Some("InvalidRecordIdError"), None, None, None, None, None, None),
      (Some("InvalidDurationError"), None, None, None, None, None, None),
      (Some("InvalidDecimalError"), None, None, None, None, None, None),
      (Some("InvalidTableError"), None, None, None, None, None, None),
      (Some("UnavailableFeatureError"), None, None, None, Some("2.3.1"), None, None),
      (Some("InvalidSessionError"), None, None, None, None, Some("\"018cc251-4f5c-7def-b4c6-000000000001\""), None),
      (Some("UnsuccessfulApiError"), None, None, None, None, None, Some("/api/widgets")),
    ])
  })

  Vitest.test("server error detail branches classify and serialize through the public surface", t => {
    let methodError =
      Surrealdb_ServerError.makeRpcErrorObject(
        ~code=(-32000),
        ~message="method blocked",
        ~kind=Surrealdb_ErrorKind.notAllowed,
        ~details=makeDetail(~kind="Method", ~details=Dict.fromArray([("name", stringToUnknown("kill"))]), ()),
        (),
      )->Surrealdb_ServerError.parseRpcError
    let notFoundTable =
      Surrealdb_ServerError.makeRpcErrorObject(
        ~code=(-32000),
        ~message="table missing",
        ~kind=Surrealdb_ErrorKind.notFound,
        ~details=makeDetail(~kind="Table", ~details=Dict.fromArray([("name", stringToUnknown("widgets"))]), ()),
        (),
      )->Surrealdb_ServerError.parseRpcError
    let duplicateRecord =
      Surrealdb_ServerError.makeRpcErrorObject(
        ~code=(-32000),
        ~message="record exists",
        ~kind=Surrealdb_ErrorKind.alreadyExists,
        ~details=makeDetail(~kind="Record", ~details=Dict.fromArray([("id", stringToUnknown("widgets:alpha"))]), ()),
        (),
      )->Surrealdb_ServerError.parseRpcError
    let timedOut =
      Surrealdb_ServerError.makeRpcErrorObject(
        ~code=(-32000),
        ~message="query timed out",
        ~kind=Surrealdb_ErrorKind.query,
        ~details=makeDetail(
          ~kind="TimedOut",
          ~details=Dict.fromArray([
            (
              "duration",
              Dict.fromArray([
                ("secs", 1->toUnknown),
                ("nanos", 2->toUnknown),
              ])->dictToUnknown,
            ),
          ]),
          (),
        ),
        (),
      )->Surrealdb_ServerError.parseRpcError
    let configuration =
      Surrealdb_ServerError.makeRpcErrorObject(
        ~code=(-32000),
        ~message="live query blocked",
        ~kind=Surrealdb_ErrorKind.configuration,
        ~details=makeDetail(~kind="LiveQueryNotSupported", ()),
        (),
      )->Surrealdb_ServerError.parseRpcError
    let serialization =
      Surrealdb_ServerError.makeRpcErrorObject(
        ~code=(-32000),
        ~message="bad decode",
        ~kind=Surrealdb_ErrorKind.serialization,
        ~details=makeDetail(~kind="Deserialization", ()),
        (),
      )->Surrealdb_ServerError.parseRpcError
    let caused =
      Surrealdb_ServerError.makeRpcErrorObject(
        ~code=(-32000),
        ~message="wrapped",
        ~kind=Surrealdb_ErrorKind.internal,
        ~cause=Surrealdb_ServerError.makeRpcErrorCause(
          ~message="inner missing table",
          ~kind=Surrealdb_ErrorKind.notFound,
          ~details=makeDetail(~kind="Table", ~details=Dict.fromArray([("name", stringToUnknown("widgets"))]), ()),
          (),
        ),
        (),
      )->Surrealdb_ServerError.parseRpcError

    t->Vitest.expect((
      methodError->Surrealdb_ServerError.asNotAllowed->Option.map(value => value->Surrealdb_ServerError.methodName),
      notFoundTable->Surrealdb_ServerError.asNotFound->Option.map(value => value->Surrealdb_ServerError.tableName),
      duplicateRecord->Surrealdb_ServerError.asAlreadyExists->Option.map(value => value->Surrealdb_ServerError.duplicateRecordId),
      timedOut
      ->Surrealdb_ServerError.asQuery
      ->Option.flatMap(Surrealdb_ServerError.timeout)
      ->Option.map(value => (value->Surrealdb_ServerError.timeoutSecs, value->Surrealdb_ServerError.timeoutNanos)),
      configuration
      ->Surrealdb_ServerError.asConfiguration
      ->Option.map(Surrealdb_ServerError.configurationIsLiveQueryNotSupported),
      serialization
      ->Surrealdb_ServerError.asSerialization
      ->Option.map(Surrealdb_ServerError.serializationIsDeserialization),
      caused->Surrealdb_ServerError.cause->Option.isSome,
    ))->Vitest.Expect.toEqual((
      Some(Some("kill")),
      Some(Some("widgets")),
      Some(Some("widgets:alpha")),
      Some((1, 2)),
      Some(true),
      Some(true),
      true,
    ))

    let payload =
      timedOut
      ->Surrealdb_ServerError.toJSON
      ->jsonObject
    let timeoutObject = payload->objectField("timeout")->Option.getOr(Dict.make())
    t->Vitest.expect((
      payload->stringField("sdkClass"),
      payload->boolField("isTimedOut"),
      timeoutObject->jsonFieldText("secs"),
      timeoutObject->jsonFieldText("nanos"),
    ))->Vitest.Expect.toEqual((
      Some("QueryError"),
      Some(true),
      Some("1"),
      Some("2"),
    ))

    let parseError =
      Surrealdb_ServerError.makeRpcErrorObject(
        ~code=(-32000),
        ~message="parse failure",
        ~kind=Surrealdb_ErrorKind.validation,
        ~details=makeDetail(~kind="Parse", ()),
        (),
      )->Surrealdb_ServerError.parseRpcError
    let parameterError =
      Surrealdb_ServerError.makeRpcErrorObject(
        ~code=(-32000),
        ~message="invalid namespace",
        ~kind=Surrealdb_ErrorKind.validation,
        ~details=makeDetail(
          ~kind="InvalidParameter",
          ~details=Dict.fromArray([("name", stringToUnknown("namespace"))]),
          (),
        ),
        (),
      )->Surrealdb_ServerError.parseRpcError
    let thrown =
      Surrealdb_ServerError.makeRpcErrorObject(
        ~code=(-32000),
        ~message="explicit throw",
        ~kind=Surrealdb_ErrorKind.thrown,
        (),
      )->Surrealdb_ServerError.parseRpcError
    let notExecuted =
      Surrealdb_ServerError.makeRpcErrorObject(
        ~code=(-32000),
        ~message="not executed",
        ~kind=Surrealdb_ErrorKind.query,
        ~details=makeDetail(~kind="NotExecuted", ()),
        (),
      )->Surrealdb_ServerError.parseRpcError
    let cancelled =
      Surrealdb_ServerError.makeRpcErrorObject(
        ~code=(-32000),
        ~message="cancelled",
        ~kind=Surrealdb_ErrorKind.query,
        ~details=makeDetail(~kind="Cancelled", ()),
        (),
      )->Surrealdb_ServerError.parseRpcError
    let invalidAuth =
      Surrealdb_ServerError.makeRpcErrorObject(
        ~code=(-32000),
        ~message="invalid auth",
        ~kind=Surrealdb_ErrorKind.notAllowed,
        ~details=makeDetail(~kind="InvalidAuth", ()),
        (),
      )->Surrealdb_ServerError.parseRpcError
    let scriptingBlocked =
      Surrealdb_ServerError.makeRpcErrorObject(
        ~code=(-32000),
        ~message="scripting blocked",
        ~kind=Surrealdb_ErrorKind.notAllowed,
        ~details=makeDetail(
          ~kind="Function",
          ~details=Dict.fromArray([("name", stringToUnknown("script::run"))]),
          (),
        ),
        (),
      )->Surrealdb_ServerError.parseRpcError
    let missingRecord =
      Surrealdb_ServerError.makeRpcErrorObject(
        ~code=(-32000),
        ~message="record missing",
        ~kind=Surrealdb_ErrorKind.notFound,
        ~details=makeDetail(~kind="Record", ~details=Dict.fromArray([("id", stringToUnknown("widgets:alpha"))]), ()),
        (),
      )->Surrealdb_ServerError.parseRpcError
    let missingMethod =
      Surrealdb_ServerError.makeRpcErrorObject(
        ~code=(-32000),
        ~message="method missing",
        ~kind=Surrealdb_ErrorKind.notFound,
        ~details=makeDetail(~kind="Method", ~details=Dict.fromArray([("name", stringToUnknown("health"))]), ()),
        (),
      )->Surrealdb_ServerError.parseRpcError
    let missingNamespace =
      Surrealdb_ServerError.makeRpcErrorObject(
        ~code=(-32000),
        ~message="namespace missing",
        ~kind=Surrealdb_ErrorKind.notFound,
        ~details=makeDetail(~kind="Namespace", ~details=Dict.fromArray([("name", stringToUnknown("app"))]), ()),
        (),
      )->Surrealdb_ServerError.parseRpcError
    let missingDatabase =
      Surrealdb_ServerError.makeRpcErrorObject(
        ~code=(-32000),
        ~message="database missing",
        ~kind=Surrealdb_ErrorKind.notFound,
        ~details=makeDetail(~kind="Database", ~details=Dict.fromArray([("name", stringToUnknown("main"))]), ()),
        (),
      )->Surrealdb_ServerError.parseRpcError
    let duplicateTable =
      Surrealdb_ServerError.makeRpcErrorObject(
        ~code=(-32000),
        ~message="table exists",
        ~kind=Surrealdb_ErrorKind.alreadyExists,
        ~details=makeDetail(~kind="Table", ~details=Dict.fromArray([("name", stringToUnknown("widgets"))]), ()),
        (),
      )->Surrealdb_ServerError.parseRpcError

    let serverJsonSummaries = [
      parseError,
      parameterError,
      configuration,
      thrown,
      notExecuted,
      timedOut,
      cancelled,
      serialization,
      methodError,
      invalidAuth,
      scriptingBlocked,
      notFoundTable,
      missingRecord,
      missingMethod,
      missingNamespace,
      missingDatabase,
      duplicateRecord,
      duplicateTable,
      caused,
    ]
    ->Array.map(error => {
        let payload = error->Surrealdb_ServerError.toJSON->jsonObject
        (
          payload->stringField("sdkClass"),
          payload->stringField("kind"),
          payload->boolField("isParseError"),
          payload->stringField("parameterName"),
          payload->boolField("isLiveQueryNotSupported"),
          payload->boolField("isNotExecuted"),
          payload->boolField("isTimedOut"),
          payload->boolField("isCancelled"),
          payload->boolField("isDeserialization"),
          payload->boolField("isInvalidAuth"),
          payload->boolField("isScriptingBlocked"),
          payload->stringField("functionName"),
          payload->stringField("tableName"),
          payload->stringField("recordId"),
          payload->stringField("methodName"),
          payload->stringField("namespaceName"),
          payload->stringField("databaseName"),
        )
      })

    t->Vitest.expect(serverJsonSummaries)->Vitest.Expect.toEqual([
      (Some("ValidationError"), Some("Validation"), Some(true), None, None, None, None, None, None, None, None, None, None, None, None, None, None),
      (Some("ValidationError"), Some("Validation"), Some(false), Some("namespace"), None, None, None, None, None, None, None, None, None, None, None, None, None),
      (Some("ConfigurationError"), Some("Configuration"), None, None, Some(true), None, None, None, None, None, None, None, None, None, None, None, None),
      (Some("ThrownError"), Some("Thrown"), None, None, None, None, None, None, None, None, None, None, None, None, None, None, None),
      (Some("QueryError"), Some("Query"), None, None, None, Some(true), Some(false), Some(false), None, None, None, None, None, None, None, None, None),
      (Some("QueryError"), Some("Query"), None, None, None, Some(false), Some(true), Some(false), None, None, None, None, None, None, None, None, None),
      (Some("QueryError"), Some("Query"), None, None, None, Some(false), Some(false), Some(true), None, None, None, None, None, None, None, None, None),
      (Some("SerializationError"), Some("Serialization"), None, None, None, None, None, None, Some(true), None, None, None, None, None, None, None, None),
      (Some("NotAllowedError"), Some("NotAllowed"), None, None, None, None, None, None, None, Some(false), Some(false), None, None, None, Some("kill"), None, None),
      (Some("NotAllowedError"), Some("NotAllowed"), None, None, None, None, None, None, None, Some(false), Some(false), None, None, None, None, None, None),
      (Some("NotAllowedError"), Some("NotAllowed"), None, None, None, None, None, None, None, Some(false), Some(false), Some("script::run"), None, None, None, None, None),
      (Some("NotFoundError"), Some("NotFound"), None, None, None, None, None, None, None, None, None, None, Some("widgets"), None, None, None, None),
      (Some("NotFoundError"), Some("NotFound"), None, None, None, None, None, None, None, None, None, None, None, Some("widgets:alpha"), None, None, None),
      (Some("NotFoundError"), Some("NotFound"), None, None, None, None, None, None, None, None, None, None, None, None, Some("health"), None, None),
      (Some("NotFoundError"), Some("NotFound"), None, None, None, None, None, None, None, None, None, None, None, None, None, Some("app"), None),
      (Some("NotFoundError"), Some("NotFound"), None, None, None, None, None, None, None, None, None, None, None, None, None, None, Some("main")),
      (Some("AlreadyExistsError"), Some("AlreadyExists"), None, None, None, None, None, None, None, None, None, None, None, Some("widgets:alpha"), None, None, None),
      (Some("AlreadyExistsError"), Some("AlreadyExists"), None, None, None, None, None, None, None, None, None, None, Some("widgets"), None, None, None, None),
      (Some("InternalError"), Some("Internal"), None, None, None, None, None, None, None, None, None, None, None, None, None, None, None),
    ])
  })
})
