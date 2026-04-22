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

let asSurrealError: t => Surrealdb_SurrealError.t
let ctor: ctor
let validationCtor: ctor
let configurationCtor: ctor
let thrownCtor: ctor
let queryCtor: ctor
let serializationCtor: ctor
let notAllowedCtor: ctor
let notFoundCtor: ctor
let alreadyExistsCtor: ctor
let internalCtor: ctor
let parseRpcError: rpcErrorObject => t
let makeRpcErrorCause: (
  ~message: string,
  ~kind: Surrealdb_ErrorKind.t=?,
  ~details: dict<unknown>=?,
  ~cause: rpcErrorCause=?,
  unit,
) => rpcErrorCause
let makeRpcErrorObject: (
  ~code: int,
  ~message: string,
  ~kind: Surrealdb_ErrorKind.t=?,
  ~details: dict<unknown>=?,
  ~cause: rpcErrorCause=?,
  unit,
) => rpcErrorObject
let kindRaw: t => string
let kind: t => Surrealdb_ErrorKind.t
let code: t => int
let detailsRaw: t => Nullable.t<detail>
let detailKind_: detail => string
let validationIsParseError: validation => bool
let validationParameterNameRaw: validation => Nullable.t<string>
let configurationIsLiveQueryNotSupported: configuration => bool
let queryIsNotExecuted: query => bool
let queryIsTimedOut: query => bool
let queryIsCancelled: query => bool
let queryTimeoutRaw: query => Nullable.t<timeout>
let timeoutSecs: timeout => int
let timeoutNanos: timeout => int
let serializationIsDeserialization: serialization => bool
let notAllowedIsTokenExpired: notAllowed => bool
let notAllowedIsInvalidAuth: notAllowed => bool
let notAllowedIsScriptingBlocked: notAllowed => bool
let notAllowedMethodNameRaw: notAllowed => Nullable.t<string>
let notAllowedFunctionNameRaw: notAllowed => Nullable.t<string>
let notFoundTableNameRaw: notFound => Nullable.t<string>
let notFoundRecordIdRaw: notFound => Nullable.t<string>
let notFoundMethodNameRaw: notFound => Nullable.t<string>
let notFoundNamespaceNameRaw: notFound => Nullable.t<string>
let notFoundDatabaseNameRaw: notFound => Nullable.t<string>
let alreadyExistsRecordIdRaw: alreadyExists => Nullable.t<string>
let alreadyExistsTableNameRaw: alreadyExists => Nullable.t<string>
let isInstance: unknown => bool
let fromUnknown: unknown => option<t>
let details: t => option<detail>
let cause: t => option<t>
let detailKind: detail => string
let detailData: detail => option<dict<Surrealdb_ErrorPayload.t>>
let parameterName: validation => option<string>
let timeout: query => option<timeout>
let methodName: notAllowed => option<string>
let functionName: notAllowed => option<string>
let tableName: notFound => option<string>
let recordId: notFound => option<string>
let missingMethodName: notFound => option<string>
let namespaceName: notFound => option<string>
let databaseName: notFound => option<string>
let duplicateRecordId: alreadyExists => option<string>
let duplicateTableName: alreadyExists => option<string>
let asValidation: t => option<validation>
let asConfiguration: t => option<configuration>
let asThrown: t => option<thrown>
let asQuery: t => option<query>
let asSerialization: t => option<serialization>
let asNotAllowed: t => option<notAllowed>
let asNotFound: t => option<notFound>
let asAlreadyExists: t => option<alreadyExists>
let asInternal: t => option<internal>
let detailToJsonObject: detail => dict<JSON.t>
let toJsonObject: t => dict<JSON.t>
let toJSON: t => JSON.t
