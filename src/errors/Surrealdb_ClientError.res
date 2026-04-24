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
type featureValue =
  | Feature(Surrealdb_Feature.t)
  | ForeignPayload(Surrealdb_ErrorPayload.t)

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

@get external unexpectedServerResponseResponseRaw: unexpectedServerResponse => unknown = "response"
@get external unsupportedEngineName: unsupportedEngine => string = "engine"
@get external httpConnectionStatus: httpConnection => int = "status"
@get external httpConnectionStatusText: httpConnection => string = "statusText"
@get external httpConnectionBuffer: httpConnection => ArrayBuffer.t = "buffer"
@get external unsupportedVersionVersion: unsupportedVersion => string = "version"
@get external unsupportedVersionMinimum: unsupportedVersion => string = "minimum"
@get external unsupportedVersionMaximum: unsupportedVersion => string = "maximum"
@get external publishCausesRaw: publish => array<unknown> = "causes"
@get external unsupportedFeatureValueRaw: unsupportedFeature => unknown = "feature"
@get external unavailableFeatureValueRaw: unavailableFeature => unknown = "feature"
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

let isInstance = error =>
  switch asCallTerminated(error) {
  | Some(_) => true
  | None =>
    switch asReconnectExhaustion(error) {
    | Some(_) => true
    | None =>
      switch asReconnectIteration(error) {
      | Some(_) => true
      | None =>
        switch asUnexpectedServerResponse(error) {
        | Some(_) => true
        | None =>
          switch asUnexpectedConnection(error) {
          | Some(_) => true
          | None =>
            switch asUnsupportedEngine(error) {
            | Some(_) => true
            | None =>
              switch asConnectionUnavailable(error) {
              | Some(_) => true
              | None =>
                switch asMissingNamespaceDatabase(error) {
                | Some(_) => true
                | None =>
                  switch asHttpConnection(error) {
                  | Some(_) => true
                  | None =>
                    switch asAuthentication(error) {
                    | Some(_) => true
                    | None =>
                      switch asLiveSubscription(error) {
                      | Some(_) => true
                      | None =>
                        switch asUnsupportedVersion(error) {
                        | Some(_) => true
                        | None =>
                          switch asExpression(error) {
                          | Some(_) => true
                          | None =>
                            switch asPublish(error) {
                            | Some(_) => true
                            | None =>
                              switch asInvalidDate(error) {
                              | Some(_) => true
                              | None =>
                                switch asUnsupportedFeature(error) {
                                | Some(_) => true
                                | None =>
                                  switch asUnavailableFeature(error) {
                                  | Some(_) => true
                                  | None =>
                                    switch asInvalidSession(error) {
                                    | Some(_) => true
                                    | None =>
                                      switch asUnsuccessfulApi(error) {
                                      | Some(_) => true
                                      | None =>
                                        switch asInvalidRecordId(error) {
                                        | Some(_) => true
                                        | None =>
                                          switch asInvalidDuration(error) {
                                          | Some(_) => true
                                          | None =>
                                            switch asInvalidDecimal(error) {
                                            | Some(_) => true
                                            | None =>
                                              switch asInvalidTable(error) {
                                              | Some(_) => true
                                              | None => false
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }

let invalidSession = error =>
  error->invalidSessionRaw->Nullable.toOption

let unexpectedServerResponseResponse = error =>
  error->unexpectedServerResponseResponseRaw->Surrealdb_ErrorPayload.fromUnknown

let publishCauses = error =>
  error->publishCausesRaw->Array.map(rawCause =>
    switch rawCause->Surrealdb_SurrealError.fromUnknown {
    | Some(causeError) => Surrealdb_SurrealError.Error(causeError)
    | None => Surrealdb_SurrealError.ForeignPayload(rawCause->Surrealdb_ErrorPayload.fromUnknown)
    }
  )

let featureValueFromUnknown = rawValue =>
  switch rawValue->Surrealdb_Feature.fromUnknown {
  | Some(feature) => Feature(feature)
  | None => ForeignPayload(rawValue->Surrealdb_ErrorPayload.fromUnknown)
  }

let unsupportedFeatureValue = error =>
  error->unsupportedFeatureValueRaw->featureValueFromUnknown

let unavailableFeatureValue = error =>
  error->unavailableFeatureValueRaw->featureValueFromUnknown

let causeToJson = cause =>
  switch cause {
  | Surrealdb_SurrealError.Error(error) => error->Surrealdb_SurrealError.toJsonObject->JSON.Encode.object
  | Surrealdb_SurrealError.ForeignPayload(payload) => payload->Surrealdb_ErrorPayload.toJSON
  }

let featureValueToJson = value =>
  switch value {
  | Feature(feature) => feature->Surrealdb_Feature.toJSON
  | ForeignPayload(payload) => payload->Surrealdb_ErrorPayload.toJSON
  }

let jsonEntry = (key, value) => [(key, value)]

let sdkClassEntries = error =>
  switch error->asCallTerminated {
  | Some(_) => jsonEntry("sdkClass", JSON.Encode.string("CallTerminatedError"))
  | None =>
    switch error->asReconnectExhaustion {
    | Some(_) => jsonEntry("sdkClass", JSON.Encode.string("ReconnectExhaustionError"))
    | None =>
      switch error->asReconnectIteration {
      | Some(_) => jsonEntry("sdkClass", JSON.Encode.string("ReconnectIterationError"))
      | None =>
        switch error->asUnexpectedServerResponse {
        | Some(_) => jsonEntry("sdkClass", JSON.Encode.string("UnexpectedServerResponseError"))
        | None =>
          switch error->asUnexpectedConnection {
          | Some(_) => jsonEntry("sdkClass", JSON.Encode.string("UnexpectedConnectionError"))
          | None =>
            switch error->asUnsupportedEngine {
            | Some(_) => jsonEntry("sdkClass", JSON.Encode.string("UnsupportedEngineError"))
            | None =>
              switch error->asConnectionUnavailable {
              | Some(_) => jsonEntry("sdkClass", JSON.Encode.string("ConnectionUnavailableError"))
              | None =>
                switch error->asMissingNamespaceDatabase {
                | Some(_) => jsonEntry("sdkClass", JSON.Encode.string("MissingNamespaceDatabaseError"))
                | None =>
                  switch error->asHttpConnection {
                  | Some(_) => jsonEntry("sdkClass", JSON.Encode.string("HttpConnectionError"))
                  | None =>
                    switch error->asAuthentication {
                    | Some(_) => jsonEntry("sdkClass", JSON.Encode.string("AuthenticationError"))
                    | None =>
                      switch error->asLiveSubscription {
                      | Some(_) => jsonEntry("sdkClass", JSON.Encode.string("LiveSubscriptionError"))
                      | None =>
                        switch error->asUnsupportedVersion {
                        | Some(_) => jsonEntry("sdkClass", JSON.Encode.string("UnsupportedVersionError"))
                        | None =>
                          switch error->asExpression {
                          | Some(_) => jsonEntry("sdkClass", JSON.Encode.string("ExpressionError"))
                          | None =>
                            switch error->asPublish {
                            | Some(_) => jsonEntry("sdkClass", JSON.Encode.string("PublishError"))
                            | None =>
                              switch error->asInvalidDate {
                              | Some(_) => jsonEntry("sdkClass", JSON.Encode.string("InvalidDateError"))
                              | None =>
                                switch error->asUnsupportedFeature {
                                | Some(_) => jsonEntry("sdkClass", JSON.Encode.string("UnsupportedFeatureError"))
                                | None =>
                                  switch error->asUnavailableFeature {
                                  | Some(_) =>
                                    jsonEntry("sdkClass", JSON.Encode.string("UnavailableFeatureError"))
                                  | None =>
                                    switch error->asInvalidSession {
                                    | Some(_) => jsonEntry("sdkClass", JSON.Encode.string("InvalidSessionError"))
                                    | None =>
                                      switch error->asUnsuccessfulApi {
                                      | Some(_) =>
                                        jsonEntry("sdkClass", JSON.Encode.string("UnsuccessfulApiError"))
                                      | None =>
                                        switch error->asInvalidRecordId {
                                        | Some(_) =>
                                          jsonEntry("sdkClass", JSON.Encode.string("InvalidRecordIdError"))
                                        | None =>
                                          switch error->asInvalidDuration {
                                          | Some(_) =>
                                            jsonEntry("sdkClass", JSON.Encode.string("InvalidDurationError"))
                                          | None =>
                                            switch error->asInvalidDecimal {
                                            | Some(_) =>
                                              jsonEntry("sdkClass", JSON.Encode.string("InvalidDecimalError"))
                                            | None =>
                                              switch error->asInvalidTable {
                                              | Some(_) =>
                                                jsonEntry("sdkClass", JSON.Encode.string("InvalidTableError"))
                                              | None => jsonEntry("sdkClass", JSON.Encode.string("SurrealError"))
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }

let toJsonObject = error =>
  [
    error->Surrealdb_SurrealError.toJsonObject->Dict.toArray,
    error->sdkClassEntries,
    switch error->asUnexpectedServerResponse {
    | Some(value) => jsonEntry("response", value->unexpectedServerResponseResponse->Surrealdb_ErrorPayload.toJSON)
    | None => []
    },
    switch error->asUnsupportedEngine {
    | Some(value) => jsonEntry("engine", JSON.Encode.string(value->unsupportedEngineName))
    | None => []
    },
    switch error->asHttpConnection {
    | Some(value) =>
      [
        ("status", JSON.Encode.int(value->httpConnectionStatus)),
        ("statusText", JSON.Encode.string(value->httpConnectionStatusText)),
        ("bufferByteLength", JSON.Encode.int(value->httpConnectionBuffer->arrayBufferByteLength)),
      ]
    | None => []
    },
    switch error->asUnsupportedVersion {
    | Some(value) =>
      [
        ("version", JSON.Encode.string(value->unsupportedVersionVersion)),
        ("minimum", JSON.Encode.string(value->unsupportedVersionMinimum)),
        ("maximum", JSON.Encode.string(value->unsupportedVersionMaximum)),
      ]
    | None => []
    },
    switch error->asPublish {
    | Some(value) => jsonEntry("causes", JSON.Encode.array(value->publishCauses->Array.map(causeToJson)))
    | None => []
    },
    switch error->asUnsupportedFeature {
    | Some(value) => jsonEntry("feature", value->unsupportedFeatureValue->featureValueToJson)
    | None => []
    },
    switch error->asUnavailableFeature {
    | Some(value) =>
      [
        ("feature", value->unavailableFeatureValue->featureValueToJson),
        ("version", JSON.Encode.string(value->unavailableFeatureVersion)),
      ]
    | None => []
    },
    switch error->asInvalidSession {
    | Some(value) =>
      jsonEntry(
        "session",
        switch value->invalidSession {
        | Some(session) => JSON.Encode.string(session->Surrealdb_Uuid.toString)
        | None => JSON.Encode.null
        },
      )
    | None => []
    },
    switch error->asUnsuccessfulApi {
    | Some(value) =>
      [
        ("path", JSON.Encode.string(value->unsuccessfulApiPath)),
        ("method", JSON.Encode.string(value->unsuccessfulApiMethod)),
        ("response", value->unsuccessfulApiResponse->Surrealdb_ApiResponse.toJSON),
      ]
    | None => []
    },
  ]
  ->Belt.Array.concatMany
  ->Dict.fromArray

let toJSON = error =>
  error->toJsonObject->JSON.Encode.object
