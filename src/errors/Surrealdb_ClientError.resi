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
let unexpectedServerResponseResponse: unexpectedServerResponse => unknown
let unsupportedEngineName: unsupportedEngine => string
let httpConnectionStatus: httpConnection => int
let httpConnectionStatusText: httpConnection => string
let httpConnectionBuffer: httpConnection => ArrayBuffer.t
let unsupportedVersionVersion: unsupportedVersion => string
let unsupportedVersionMinimum: unsupportedVersion => string
let unsupportedVersionMaximum: unsupportedVersion => string
let publishCauses: publish => array<unknown>
let unsupportedFeatureValue: unsupportedFeature => unknown
let unavailableFeatureValue: unavailableFeature => unknown
let unavailableFeatureVersion: unavailableFeature => string
let invalidSessionRaw: invalidSession => Nullable.t<Surrealdb_Uuid.t>
let unsuccessfulApiPath: unsuccessfulApi => string
let unsuccessfulApiMethod: unsuccessfulApi => string
let unsuccessfulApiResponse: unsuccessfulApi => Surrealdb_ApiResponse.t
let arrayBufferByteLength: ArrayBuffer.t => int
let asCallTerminated: 'a => option<callTerminated>
let asReconnectExhaustion: 'a => option<reconnectExhaustion>
let asReconnectIteration: 'a => option<reconnectIteration>
let asUnexpectedServerResponse: 'a => option<unexpectedServerResponse>
let asUnexpectedConnection: 'a => option<unexpectedConnection>
let asUnsupportedEngine: 'a => option<unsupportedEngine>
let asConnectionUnavailable: 'a => option<connectionUnavailable>
let asMissingNamespaceDatabase: 'a => option<missingNamespaceDatabase>
let asHttpConnection: 'a => option<httpConnection>
let asAuthentication: 'a => option<authentication>
let asLiveSubscription: 'a => option<liveSubscription>
let asUnsupportedVersion: 'a => option<unsupportedVersion>
let asExpression: 'a => option<expression>
let asPublish: 'a => option<publish>
let asInvalidDate: 'a => option<invalidDate>
let asUnsupportedFeature: 'a => option<unsupportedFeature>
let asUnavailableFeature: 'a => option<unavailableFeature>
let asInvalidSession: 'a => option<invalidSession>
let asUnsuccessfulApi: 'a => option<unsuccessfulApi>
let asInvalidRecordId: 'a => option<invalidRecordId>
let asInvalidDuration: 'a => option<invalidDuration>
let asInvalidDecimal: 'a => option<invalidDecimal>
let asInvalidTable: 'a => option<invalidTable>
let invalidSession: invalidSession => option<Surrealdb_Uuid.t>
let toJsonObject: Surrealdb_SurrealError.t => dict<JSON.t>
let toJSON: Surrealdb_SurrealError.t => JSON.t
