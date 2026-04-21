// src/bindings/Surrealdb_ClientError.res — SurrealDB client-side error binding.
// Concern: bind the non-server SurrealError subclasses raised by the SDK, driver,
// API layer, live subscriptions, and value constructors.
type ctor
type callTerminated
type reconnectExhaustion
type reconnectIteration
type unexpectedServerResponse
type unexpectedConnection
type unsupportedEngine
type connectionUnavailable
type missingNamespaceDatabase
type httpConnection
type authentication
type liveSubscription
type unsupportedVersion
type expression
type publish
type invalidDate
type unsupportedFeature
type unavailableFeature
type invalidSession
type unsuccessfulApi
type invalidRecordId
type invalidDuration
type invalidDecimal
type invalidTable

external toUnknown: 'a => unknown = "%identity"
external unsafeCallTerminatedFromUnknown: unknown => callTerminated = "%identity"
external unsafeReconnectExhaustionFromUnknown: unknown => reconnectExhaustion = "%identity"
external unsafeReconnectIterationFromUnknown: unknown => reconnectIteration = "%identity"
external unsafeUnexpectedServerResponseFromUnknown: unknown => unexpectedServerResponse = "%identity"
external unsafeUnexpectedConnectionFromUnknown: unknown => unexpectedConnection = "%identity"
external unsafeUnsupportedEngineFromUnknown: unknown => unsupportedEngine = "%identity"
external unsafeConnectionUnavailableFromUnknown: unknown => connectionUnavailable = "%identity"
external unsafeMissingNamespaceDatabaseFromUnknown: unknown => missingNamespaceDatabase = "%identity"
external unsafeHttpConnectionFromUnknown: unknown => httpConnection = "%identity"
external unsafeAuthenticationFromUnknown: unknown => authentication = "%identity"
external unsafeLiveSubscriptionFromUnknown: unknown => liveSubscription = "%identity"
external unsafeUnsupportedVersionFromUnknown: unknown => unsupportedVersion = "%identity"
external unsafeExpressionFromUnknown: unknown => expression = "%identity"
external unsafePublishFromUnknown: unknown => publish = "%identity"
external unsafeInvalidDateFromUnknown: unknown => invalidDate = "%identity"
external unsafeUnsupportedFeatureFromUnknown: unknown => unsupportedFeature = "%identity"
external unsafeUnavailableFeatureFromUnknown: unknown => unavailableFeature = "%identity"
external unsafeInvalidSessionFromUnknown: unknown => invalidSession = "%identity"
external unsafeUnsuccessfulApiFromUnknown: unknown => unsuccessfulApi = "%identity"
external unsafeInvalidRecordIdFromUnknown: unknown => invalidRecordId = "%identity"
external unsafeInvalidDurationFromUnknown: unknown => invalidDuration = "%identity"
external unsafeInvalidDecimalFromUnknown: unknown => invalidDecimal = "%identity"
external unsafeInvalidTableFromUnknown: unknown => invalidTable = "%identity"

@module("surrealdb") external callTerminatedCtor: ctor = "CallTerminatedError"
@module("surrealdb") external reconnectExhaustionCtor: ctor = "ReconnectExhaustionError"
@module("surrealdb") external reconnectIterationCtor: ctor = "ReconnectIterationError"
@module("surrealdb") external unexpectedServerResponseCtor: ctor = "UnexpectedServerResponseError"
@module("surrealdb") external unexpectedConnectionCtor: ctor = "UnexpectedConnectionError"
@module("surrealdb") external unsupportedEngineCtor: ctor = "UnsupportedEngineError"
@module("surrealdb") external connectionUnavailableCtor: ctor = "ConnectionUnavailableError"
@module("surrealdb") external missingNamespaceDatabaseCtor: ctor = "MissingNamespaceDatabaseError"
@module("surrealdb") external httpConnectionCtor: ctor = "HttpConnectionError"
@module("surrealdb") external authenticationCtor: ctor = "AuthenticationError"
@module("surrealdb") external liveSubscriptionCtor: ctor = "LiveSubscriptionError"
@module("surrealdb") external unsupportedVersionCtor: ctor = "UnsupportedVersionError"
@module("surrealdb") external expressionCtor: ctor = "ExpressionError"
@module("surrealdb") external publishCtor: ctor = "PublishError"
@module("surrealdb") external invalidDateCtor: ctor = "InvalidDateError"
@module("surrealdb") external unsupportedFeatureCtor: ctor = "UnsupportedFeatureError"
@module("surrealdb") external unavailableFeatureCtor: ctor = "UnavailableFeatureError"
@module("surrealdb") external invalidSessionCtor: ctor = "InvalidSessionError"
@module("surrealdb") external unsuccessfulApiCtor: ctor = "UnsuccessfulApiError"
@module("surrealdb") external invalidRecordIdCtor: ctor = "InvalidRecordIdError"
@module("surrealdb") external invalidDurationCtor: ctor = "InvalidDurationError"
@module("surrealdb") external invalidDecimalCtor: ctor = "InvalidDecimalError"
@module("surrealdb") external invalidTableCtor: ctor = "InvalidTableError"

@get external unexpectedServerResponseResponse: unexpectedServerResponse => unknown = "response"
@get external unsupportedEngineName: unsupportedEngine => string = "engine"
@get external httpConnectionStatus: httpConnection => int = "status"
@get external httpConnectionStatusText: httpConnection => string = "statusText"
@get external httpConnectionBuffer: httpConnection => ArrayBuffer.t = "buffer"
@get external unsupportedVersionVersion: unsupportedVersion => string = "version"
@get external unsupportedVersionMinimum: unsupportedVersion => string = "minimum"
@get external unsupportedVersionMaximum: unsupportedVersion => string = "maximum"
@get external publishCauses: publish => array<unknown> = "causes"
@get external unsupportedFeatureValue: unsupportedFeature => unknown = "feature"
@get external unavailableFeatureValue: unavailableFeature => unknown = "feature"
@get external unavailableFeatureVersion: unavailableFeature => string = "version"
@get external invalidSessionRaw: invalidSession => Nullable.t<Surrealdb_Uuid.t> = "session"
@get external unsuccessfulApiPath: unsuccessfulApi => string = "path"
@get external unsuccessfulApiMethod: unsuccessfulApi => string = "method"
@get external unsuccessfulApiResponse: unsuccessfulApi => Surrealdb_ApiResponse.t = "response"
@get external arrayBufferByteLength: ArrayBuffer.t => int = "byteLength"

let fromUnknownWith = (~value, ~ctor, cast) =>
  if JsTypeReflection.instanceOfClass(~instance=value, ~class_=ctor) {
    Some(cast(value))
  } else {
    None
  }

let asCallTerminated = error =>
  fromUnknownWith(~value=toUnknown(error), ~ctor=callTerminatedCtor, unsafeCallTerminatedFromUnknown)

let asReconnectExhaustion = error =>
  fromUnknownWith(
    ~value=toUnknown(error),
    ~ctor=reconnectExhaustionCtor,
    unsafeReconnectExhaustionFromUnknown,
  )

let asReconnectIteration = error =>
  fromUnknownWith(
    ~value=toUnknown(error),
    ~ctor=reconnectIterationCtor,
    unsafeReconnectIterationFromUnknown,
  )

let asUnexpectedServerResponse = error =>
  fromUnknownWith(
    ~value=toUnknown(error),
    ~ctor=unexpectedServerResponseCtor,
    unsafeUnexpectedServerResponseFromUnknown,
  )

let asUnexpectedConnection = error =>
  fromUnknownWith(
    ~value=toUnknown(error),
    ~ctor=unexpectedConnectionCtor,
    unsafeUnexpectedConnectionFromUnknown,
  )

let asUnsupportedEngine = error =>
  fromUnknownWith(~value=toUnknown(error), ~ctor=unsupportedEngineCtor, unsafeUnsupportedEngineFromUnknown)

let asConnectionUnavailable = error =>
  fromUnknownWith(
    ~value=toUnknown(error),
    ~ctor=connectionUnavailableCtor,
    unsafeConnectionUnavailableFromUnknown,
  )

let asMissingNamespaceDatabase = error =>
  fromUnknownWith(
    ~value=toUnknown(error),
    ~ctor=missingNamespaceDatabaseCtor,
    unsafeMissingNamespaceDatabaseFromUnknown,
  )

let asHttpConnection = error =>
  fromUnknownWith(~value=toUnknown(error), ~ctor=httpConnectionCtor, unsafeHttpConnectionFromUnknown)

let asAuthentication = error =>
  fromUnknownWith(~value=toUnknown(error), ~ctor=authenticationCtor, unsafeAuthenticationFromUnknown)

let asLiveSubscription = error =>
  fromUnknownWith(~value=toUnknown(error), ~ctor=liveSubscriptionCtor, unsafeLiveSubscriptionFromUnknown)

let asUnsupportedVersion = error =>
  fromUnknownWith(
    ~value=toUnknown(error),
    ~ctor=unsupportedVersionCtor,
    unsafeUnsupportedVersionFromUnknown,
  )

let asExpression = error =>
  fromUnknownWith(~value=toUnknown(error), ~ctor=expressionCtor, unsafeExpressionFromUnknown)

let asPublish = error =>
  fromUnknownWith(~value=toUnknown(error), ~ctor=publishCtor, unsafePublishFromUnknown)

let asInvalidDate = error =>
  fromUnknownWith(~value=toUnknown(error), ~ctor=invalidDateCtor, unsafeInvalidDateFromUnknown)

let asUnsupportedFeature = error =>
  fromUnknownWith(
    ~value=toUnknown(error),
    ~ctor=unsupportedFeatureCtor,
    unsafeUnsupportedFeatureFromUnknown,
  )

let asUnavailableFeature = error =>
  fromUnknownWith(
    ~value=toUnknown(error),
    ~ctor=unavailableFeatureCtor,
    unsafeUnavailableFeatureFromUnknown,
  )

let asInvalidSession = error =>
  fromUnknownWith(~value=toUnknown(error), ~ctor=invalidSessionCtor, unsafeInvalidSessionFromUnknown)

let asUnsuccessfulApi = error =>
  fromUnknownWith(~value=toUnknown(error), ~ctor=unsuccessfulApiCtor, unsafeUnsuccessfulApiFromUnknown)

let asInvalidRecordId = error =>
  fromUnknownWith(~value=toUnknown(error), ~ctor=invalidRecordIdCtor, unsafeInvalidRecordIdFromUnknown)

let asInvalidDuration = error =>
  fromUnknownWith(~value=toUnknown(error), ~ctor=invalidDurationCtor, unsafeInvalidDurationFromUnknown)

let asInvalidDecimal = error =>
  fromUnknownWith(~value=toUnknown(error), ~ctor=invalidDecimalCtor, unsafeInvalidDecimalFromUnknown)

let asInvalidTable = error =>
  fromUnknownWith(~value=toUnknown(error), ~ctor=invalidTableCtor, unsafeInvalidTableFromUnknown)

let invalidSession = error =>
  error->invalidSessionRaw->Nullable.toOption

let setSdkClass = (payload, value) =>
  payload->Dict.set("sdkClass", JSON.Encode.string(value))

let toJsonObject = error => {
  let payload = error->Surrealdb_SurrealError.toJsonObject
  payload->setSdkClass("SurrealError")

  switch error->asCallTerminated {
  | Some(_) => payload->setSdkClass("CallTerminatedError")
  | None => ()
  }
  switch error->asReconnectExhaustion {
  | Some(_) => payload->setSdkClass("ReconnectExhaustionError")
  | None => ()
  }
  switch error->asReconnectIteration {
  | Some(_) => payload->setSdkClass("ReconnectIterationError")
  | None => ()
  }
  switch error->asUnexpectedServerResponse {
  | Some(value) =>
    payload->setSdkClass("UnexpectedServerResponseError")
    payload->Dict.set(
      "response",
      value->unexpectedServerResponseResponse->Surrealdb_Value.fromUnknown->Surrealdb_Value.toJSON,
    )
  | None => ()
  }
  switch error->asUnexpectedConnection {
  | Some(_) => payload->setSdkClass("UnexpectedConnectionError")
  | None => ()
  }
  switch error->asUnsupportedEngine {
  | Some(value) =>
    payload->setSdkClass("UnsupportedEngineError")
    payload->Dict.set("engine", JSON.Encode.string(value->unsupportedEngineName))
  | None => ()
  }
  switch error->asConnectionUnavailable {
  | Some(_) => payload->setSdkClass("ConnectionUnavailableError")
  | None => ()
  }
  switch error->asMissingNamespaceDatabase {
  | Some(_) => payload->setSdkClass("MissingNamespaceDatabaseError")
  | None => ()
  }
  switch error->asHttpConnection {
  | Some(value) =>
    payload->setSdkClass("HttpConnectionError")
    payload->Dict.set("status", JSON.Encode.int(value->httpConnectionStatus))
    payload->Dict.set("statusText", JSON.Encode.string(value->httpConnectionStatusText))
    payload->Dict.set(
      "bufferByteLength",
      JSON.Encode.int(value->httpConnectionBuffer->arrayBufferByteLength),
    )
  | None => ()
  }
  switch error->asAuthentication {
  | Some(_) => payload->setSdkClass("AuthenticationError")
  | None => ()
  }
  switch error->asLiveSubscription {
  | Some(_) => payload->setSdkClass("LiveSubscriptionError")
  | None => ()
  }
  switch error->asUnsupportedVersion {
  | Some(value) =>
    payload->setSdkClass("UnsupportedVersionError")
    payload->Dict.set("version", JSON.Encode.string(value->unsupportedVersionVersion))
    payload->Dict.set("minimum", JSON.Encode.string(value->unsupportedVersionMinimum))
    payload->Dict.set("maximum", JSON.Encode.string(value->unsupportedVersionMaximum))
  | None => ()
  }
  switch error->asExpression {
  | Some(_) => payload->setSdkClass("ExpressionError")
  | None => ()
  }
  switch error->asPublish {
  | Some(value) =>
    payload->setSdkClass("PublishError")
    payload->Dict.set(
      "causes",
      JSON.Encode.array(
        value->publishCauses->Array.map(cause => cause->Surrealdb_Value.fromUnknown->Surrealdb_Value.toJSON),
      ),
    )
  | None => ()
  }
  switch error->asInvalidDate {
  | Some(_) => payload->setSdkClass("InvalidDateError")
  | None => ()
  }
  switch error->asUnsupportedFeature {
  | Some(value) =>
    payload->setSdkClass("UnsupportedFeatureError")
    payload->Dict.set(
      "feature",
      value->unsupportedFeatureValue->Surrealdb_Feature.toJSONFromUnknown,
    )
  | None => ()
  }
  switch error->asUnavailableFeature {
  | Some(value) =>
    payload->setSdkClass("UnavailableFeatureError")
    payload->Dict.set(
      "feature",
      value->unavailableFeatureValue->Surrealdb_Feature.toJSONFromUnknown,
    )
    payload->Dict.set("version", JSON.Encode.string(value->unavailableFeatureVersion))
  | None => ()
  }
  switch error->asInvalidSession {
  | Some(value) =>
    payload->setSdkClass("InvalidSessionError")
    switch value->invalidSession {
    | Some(session) => payload->Dict.set("session", JSON.Encode.string(session->Surrealdb_Uuid.toString))
    | None => payload->Dict.set("session", JSON.Encode.null)
    }
  | None => ()
  }
  switch error->asUnsuccessfulApi {
  | Some(value) =>
    payload->setSdkClass("UnsuccessfulApiError")
    payload->Dict.set("path", JSON.Encode.string(value->unsuccessfulApiPath))
    payload->Dict.set("method", JSON.Encode.string(value->unsuccessfulApiMethod))
    payload->Dict.set("response", value->unsuccessfulApiResponse->Surrealdb_ApiResponse.toJSON)
  | None => ()
  }
  switch error->asInvalidRecordId {
  | Some(_) => payload->setSdkClass("InvalidRecordIdError")
  | None => ()
  }
  switch error->asInvalidDuration {
  | Some(_) => payload->setSdkClass("InvalidDurationError")
  | None => ()
  }
  switch error->asInvalidDecimal {
  | Some(_) => payload->setSdkClass("InvalidDecimalError")
  | None => ()
  }
  switch error->asInvalidTable {
  | Some(_) => payload->setSdkClass("InvalidTableError")
  | None => ()
  }
  payload
}

let toJSON = error =>
  error->toJsonObject->JSON.Encode.object
