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

let callTerminatedCtor: ctor
let reconnectExhaustionCtor: ctor
let reconnectIterationCtor: ctor
let unexpectedServerResponseCtor: ctor
let unexpectedConnectionCtor: ctor
let unsupportedEngineCtor: ctor
let connectionUnavailableCtor: ctor
let missingNamespaceDatabaseCtor: ctor
let httpConnectionCtor: ctor
let authenticationCtor: ctor
let liveSubscriptionCtor: ctor
let unsupportedVersionCtor: ctor
let expressionCtor: ctor
let publishCtor: ctor
let invalidDateCtor: ctor
let unsupportedFeatureCtor: ctor
let unavailableFeatureCtor: ctor
let invalidSessionCtor: ctor
let unsuccessfulApiCtor: ctor
let invalidRecordIdCtor: ctor
let invalidDurationCtor: ctor
let invalidDecimalCtor: ctor
let invalidTableCtor: ctor
let unexpectedServerResponseResponse: unexpectedServerResponse => Surrealdb_ErrorPayload.t
let unsupportedEngineName: unsupportedEngine => string
let httpConnectionStatus: httpConnection => int
let httpConnectionStatusText: httpConnection => string
let httpConnectionBuffer: httpConnection => ArrayBuffer.t
let unsupportedVersionVersion: unsupportedVersion => string
let unsupportedVersionMinimum: unsupportedVersion => string
let unsupportedVersionMaximum: unsupportedVersion => string
let publishCauses: publish => array<Surrealdb_SurrealError.cause>
let unsupportedFeatureValue: unsupportedFeature => featureValue
let unavailableFeatureValue: unavailableFeature => featureValue
let unavailableFeatureVersion: unavailableFeature => string
let invalidSessionRaw: invalidSession => Nullable.t<Surrealdb_Uuid.t>
let unsuccessfulApiPath: unsuccessfulApi => string
let unsuccessfulApiMethod: unsuccessfulApi => string
let unsuccessfulApiResponse: unsuccessfulApi => Surrealdb_ApiResponse.t
let arrayBufferByteLength: ArrayBuffer.t => int
let isInstance: unknown => bool
let asCallTerminated: unknown => option<callTerminated>
let asReconnectExhaustion: unknown => option<reconnectExhaustion>
let asReconnectIteration: unknown => option<reconnectIteration>
let asUnexpectedServerResponse: unknown => option<unexpectedServerResponse>
let asUnexpectedConnection: unknown => option<unexpectedConnection>
let asUnsupportedEngine: unknown => option<unsupportedEngine>
let asConnectionUnavailable: unknown => option<connectionUnavailable>
let asMissingNamespaceDatabase: unknown => option<missingNamespaceDatabase>
let asHttpConnection: unknown => option<httpConnection>
let asAuthentication: unknown => option<authentication>
let asLiveSubscription: unknown => option<liveSubscription>
let asUnsupportedVersion: unknown => option<unsupportedVersion>
let asExpression: unknown => option<expression>
let asPublish: unknown => option<publish>
let asInvalidDate: unknown => option<invalidDate>
let asUnsupportedFeature: unknown => option<unsupportedFeature>
let asUnavailableFeature: unknown => option<unavailableFeature>
let asInvalidSession: unknown => option<invalidSession>
let asUnsuccessfulApi: unknown => option<unsuccessfulApi>
let asInvalidRecordId: unknown => option<invalidRecordId>
let asInvalidDuration: unknown => option<invalidDuration>
let asInvalidDecimal: unknown => option<invalidDecimal>
let asInvalidTable: unknown => option<invalidTable>
let invalidSession: invalidSession => option<Surrealdb_Uuid.t>
let toJsonObject: Surrealdb_SurrealError.t => dict<JSON.t>
let toJSON: Surrealdb_SurrealError.t => JSON.t
