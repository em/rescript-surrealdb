// src/bindings/Surrealdb_ServerError.res — SurrealDB server error binding.
// Concern: bind the structured ServerError hierarchy returned by the database.
// Source: surrealdb.d.ts — ServerError has kind, code, details, cause, and typed
// subclasses with runtime getters for structured error inspection.
type t
type detail
type timeout
type ctor
type rpcErrorCause
type rpcErrorObject
type validation
type configuration
type thrown
type query
type serialization
type notAllowed
type notFound
type alreadyExists
type internal

external toUnknown: 'a => unknown = "%identity"
external unsafeFromUnknown: unknown => t = "%identity"
external unsafeValidationFromUnknown: unknown => validation = "%identity"
external unsafeConfigurationFromUnknown: unknown => configuration = "%identity"
external unsafeThrownFromUnknown: unknown => thrown = "%identity"
external unsafeQueryFromUnknown: unknown => query = "%identity"
external unsafeSerializationFromUnknown: unknown => serialization = "%identity"
external unsafeNotAllowedFromUnknown: unknown => notAllowed = "%identity"
external unsafeNotFoundFromUnknown: unknown => notFound = "%identity"
external unsafeAlreadyExistsFromUnknown: unknown => alreadyExists = "%identity"
external unsafeInternalFromUnknown: unknown => internal = "%identity"

external asSurrealError: t => Surrealdb_SurrealError.t = "%identity"

@module("surrealdb") external ctor: ctor = "ServerError"
@module("surrealdb") external validationCtor: ctor = "ValidationError"
@module("surrealdb") external configurationCtor: ctor = "ConfigurationError"
@module("surrealdb") external thrownCtor: ctor = "ThrownError"
@module("surrealdb") external queryCtor: ctor = "QueryError"
@module("surrealdb") external serializationCtor: ctor = "SerializationError"
@module("surrealdb") external notAllowedCtor: ctor = "NotAllowedError"
@module("surrealdb") external notFoundCtor: ctor = "NotFoundError"
@module("surrealdb") external alreadyExistsCtor: ctor = "AlreadyExistsError"
@module("surrealdb") external internalCtor: ctor = "InternalError"
@module("surrealdb") external parseRpcError: rpcErrorObject => t = "parseRpcError"

@obj
external makeRpcErrorCauseRaw: (
  ~message: string,
  ~kind: string=?,
  ~details: dict<unknown>=?,
  ~cause: rpcErrorCause=?,
  unit,
) => rpcErrorCause = ""

@obj
external makeRpcErrorObjectRaw: (
  ~code: int,
  ~message: string,
  ~kind: string=?,
  ~details: dict<unknown>=?,
  ~cause: rpcErrorCause=?,
  unit,
) => rpcErrorObject = ""

@get external kindRaw: t => string = "kind"
@get external code: t => int = "code"
@get external detailsRaw: t => Nullable.t<detail> = "details"
@get external causeRaw: t => Nullable.t<t> = "cause"

@get external detailKind_: detail => string = "kind"
@get external detailDataRaw: detail => Nullable.t<dict<unknown>> = "details"

@get external validationIsParseError: validation => bool = "isParseError"
@get external validationParameterNameRaw: validation => Nullable.t<string> = "parameterName"

@get external configurationIsLiveQueryNotSupported: configuration => bool = "isLiveQueryNotSupported"

@get external queryIsNotExecuted: query => bool = "isNotExecuted"
@get external queryIsTimedOut: query => bool = "isTimedOut"
@get external queryIsCancelled: query => bool = "isCancelled"
@get external queryTimeoutRaw: query => Nullable.t<timeout> = "timeout"
@get external timeoutSecs: timeout => int = "secs"
@get external timeoutNanos: timeout => int = "nanos"

@get external serializationIsDeserialization: serialization => bool = "isDeserialization"

@get external notAllowedIsTokenExpired: notAllowed => bool = "isTokenExpired"
@get external notAllowedIsInvalidAuth: notAllowed => bool = "isInvalidAuth"
@get external notAllowedIsScriptingBlocked: notAllowed => bool = "isScriptingBlocked"
@get external notAllowedMethodNameRaw: notAllowed => Nullable.t<string> = "methodName"
@get external notAllowedFunctionNameRaw: notAllowed => Nullable.t<string> = "functionName"

@get external notFoundTableNameRaw: notFound => Nullable.t<string> = "tableName"
@get external notFoundRecordIdRaw: notFound => Nullable.t<string> = "recordId"
@get external notFoundMethodNameRaw: notFound => Nullable.t<string> = "methodName"
@get external notFoundNamespaceNameRaw: notFound => Nullable.t<string> = "namespaceName"
@get external notFoundDatabaseNameRaw: notFound => Nullable.t<string> = "databaseName"

@get external alreadyExistsRecordIdRaw: alreadyExists => Nullable.t<string> = "recordId"
@get external alreadyExistsTableNameRaw: alreadyExists => Nullable.t<string> = "tableName"

let fromUnknownWith = (~value, ~ctor, cast) =>
  if JsTypeReflection.instanceOfClass(~instance=value, ~class_=ctor) {
    Some(cast(value))
  } else {
    None
  }

let isInstance = value =>
  JsTypeReflection.instanceOfClass(~instance=value, ~class_=ctor)

let fromUnknown = value =>
  fromUnknownWith(~value, ~ctor, unsafeFromUnknown)

let makeRpcErrorCause = (~message, ~kind=?, ~details=?, ~cause=?, ()) =>
  switch kind {
  | Some(value) =>
    makeRpcErrorCauseRaw(~message, ~kind=value->Surrealdb_ErrorKind.toString, ~details?, ~cause?, ())
  | None => makeRpcErrorCauseRaw(~message, ~details?, ~cause?, ())
  }

let makeRpcErrorObject = (~code, ~message, ~kind=?, ~details=?, ~cause=?, ()) =>
  switch kind {
  | Some(value) =>
    makeRpcErrorObjectRaw(
      ~code,
      ~message,
      ~kind=value->Surrealdb_ErrorKind.toString,
      ~details?,
      ~cause?,
      (),
    )
  | None => makeRpcErrorObjectRaw(~code, ~message, ~details?, ~cause?, ())
  }

let details = error =>
  error->detailsRaw->Nullable.toOption

let cause = error =>
  error->causeRaw->Nullable.toOption

let kind = error =>
  error->kindRaw->Surrealdb_ErrorKind.fromString

let detailKind = detail =>
  detail->detailKind_

let detailData = detail =>
  detail->detailDataRaw->Nullable.toOption->Option.map(Surrealdb_ErrorPayload.classifyDict)

let parameterName = error =>
  error->validationParameterNameRaw->Nullable.toOption

let timeout = error =>
  error->queryTimeoutRaw->Nullable.toOption

let methodName = error =>
  error->notAllowedMethodNameRaw->Nullable.toOption

let functionName = error =>
  error->notAllowedFunctionNameRaw->Nullable.toOption

let tableName = error =>
  error->notFoundTableNameRaw->Nullable.toOption

let recordId = error =>
  error->notFoundRecordIdRaw->Nullable.toOption

let missingMethodName = error =>
  error->notFoundMethodNameRaw->Nullable.toOption

let namespaceName = error =>
  error->notFoundNamespaceNameRaw->Nullable.toOption

let databaseName = error =>
  error->notFoundDatabaseNameRaw->Nullable.toOption

let duplicateRecordId = error =>
  error->alreadyExistsRecordIdRaw->Nullable.toOption

let duplicateTableName = error =>
  error->alreadyExistsTableNameRaw->Nullable.toOption

let asValidation = error =>
  fromUnknownWith(~value=toUnknown(error), ~ctor=validationCtor, unsafeValidationFromUnknown)

let asConfiguration = error =>
  fromUnknownWith(~value=toUnknown(error), ~ctor=configurationCtor, unsafeConfigurationFromUnknown)

let asThrown = error =>
  fromUnknownWith(~value=toUnknown(error), ~ctor=thrownCtor, unsafeThrownFromUnknown)

let asQuery = error =>
  fromUnknownWith(~value=toUnknown(error), ~ctor=queryCtor, unsafeQueryFromUnknown)

let asSerialization = error =>
  fromUnknownWith(~value=toUnknown(error), ~ctor=serializationCtor, unsafeSerializationFromUnknown)

let asNotAllowed = error =>
  fromUnknownWith(~value=toUnknown(error), ~ctor=notAllowedCtor, unsafeNotAllowedFromUnknown)

let asNotFound = error =>
  fromUnknownWith(~value=toUnknown(error), ~ctor=notFoundCtor, unsafeNotFoundFromUnknown)

let asAlreadyExists = error =>
  fromUnknownWith(~value=toUnknown(error), ~ctor=alreadyExistsCtor, unsafeAlreadyExistsFromUnknown)

let asInternal = error =>
  fromUnknownWith(~value=toUnknown(error), ~ctor=internalCtor, unsafeInternalFromUnknown)

let detailToJsonObject = detail => {
  let payload = Dict.make()
  payload->Dict.set("kind", JSON.Encode.string(detail->detailKind))
  switch detail->detailData {
  | Some(values) =>
    let detailsJson = Dict.make()
    values->Dict.toArray->Array.forEach(((key, value)) => detailsJson->Dict.set(key, value->Surrealdb_ErrorPayload.toJSON))
    payload->Dict.set("details", JSON.Encode.object(detailsJson))
  | None => ()
  }
  payload
}

let setOptionalString = (payload, key, value) =>
  switch value {
  | Some(text) => payload->Dict.set(key, JSON.Encode.string(text))
  | None => ()
  }

let rec toJsonObject = error => {
  let payload = error->asSurrealError->Surrealdb_SurrealError.toJsonObject
  payload->Dict.set("sdkClass", JSON.Encode.string("ServerError"))
  payload->Dict.set("kind", JSON.Encode.string(error->kind->Surrealdb_ErrorKind.toString))
  payload->Dict.set("code", JSON.Encode.int(error->code))
  switch error->details {
  | Some(value) => payload->Dict.set("details", value->detailToJsonObject->JSON.Encode.object)
  | None => ()
  }
  switch error->cause {
  | Some(value) => payload->Dict.set("cause", value->toJsonObject->JSON.Encode.object)
  | None => ()
  }

  switch error->asValidation {
  | Some(value) =>
    payload->Dict.set("sdkClass", JSON.Encode.string("ValidationError"))
    payload->Dict.set("isParseError", JSON.Encode.bool(value->validationIsParseError))
    payload->setOptionalString("parameterName", value->parameterName)
  | None => ()
  }
  switch error->asConfiguration {
  | Some(value) =>
    payload->Dict.set("sdkClass", JSON.Encode.string("ConfigurationError"))
    payload->Dict.set(
      "isLiveQueryNotSupported",
      JSON.Encode.bool(value->configurationIsLiveQueryNotSupported),
    )
  | None => ()
  }
  switch error->asThrown {
  | Some(_) => payload->Dict.set("sdkClass", JSON.Encode.string("ThrownError"))
  | None => ()
  }
  switch error->asQuery {
  | Some(value) =>
    payload->Dict.set("sdkClass", JSON.Encode.string("QueryError"))
    payload->Dict.set("isNotExecuted", JSON.Encode.bool(value->queryIsNotExecuted))
    payload->Dict.set("isTimedOut", JSON.Encode.bool(value->queryIsTimedOut))
    payload->Dict.set("isCancelled", JSON.Encode.bool(value->queryIsCancelled))
    switch value->timeout {
    | Some(timeout) =>
      let timeoutJson = Dict.make()
      timeoutJson->Dict.set("secs", JSON.Encode.int(timeout->timeoutSecs))
      timeoutJson->Dict.set("nanos", JSON.Encode.int(timeout->timeoutNanos))
      payload->Dict.set("timeout", JSON.Encode.object(timeoutJson))
    | None => ()
    }
  | None => ()
  }
  switch error->asSerialization {
  | Some(value) =>
    payload->Dict.set("sdkClass", JSON.Encode.string("SerializationError"))
    payload->Dict.set(
      "isDeserialization",
      JSON.Encode.bool(value->serializationIsDeserialization),
    )
  | None => ()
  }
  switch error->asNotAllowed {
  | Some(value) =>
    payload->Dict.set("sdkClass", JSON.Encode.string("NotAllowedError"))
    payload->Dict.set("isTokenExpired", JSON.Encode.bool(value->notAllowedIsTokenExpired))
    payload->Dict.set("isInvalidAuth", JSON.Encode.bool(value->notAllowedIsInvalidAuth))
    payload->Dict.set("isScriptingBlocked", JSON.Encode.bool(value->notAllowedIsScriptingBlocked))
    payload->setOptionalString("methodName", value->methodName)
    payload->setOptionalString("functionName", value->functionName)
  | None => ()
  }
  switch error->asNotFound {
  | Some(value) =>
    payload->Dict.set("sdkClass", JSON.Encode.string("NotFoundError"))
    payload->setOptionalString("tableName", value->tableName)
    payload->setOptionalString("recordId", value->recordId)
    payload->setOptionalString("methodName", value->missingMethodName)
    payload->setOptionalString("namespaceName", value->namespaceName)
    payload->setOptionalString("databaseName", value->databaseName)
  | None => ()
  }
  switch error->asAlreadyExists {
  | Some(value) =>
    payload->Dict.set("sdkClass", JSON.Encode.string("AlreadyExistsError"))
    payload->setOptionalString("recordId", value->duplicateRecordId)
    payload->setOptionalString("tableName", value->duplicateTableName)
  | None => ()
  }
  switch error->asInternal {
  | Some(_) => payload->Dict.set("sdkClass", JSON.Encode.string("InternalError"))
  | None => ()
  }
  payload
}

let toJSON = error =>
  error->toJsonObject->JSON.Encode.object
