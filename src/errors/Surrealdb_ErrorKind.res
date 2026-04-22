// src/bindings/Surrealdb_ErrorKind.res — SurrealDB server error kind values.
// Concern: expose known server error kinds as a closed package variant with a raw
// fallback for forward-compatible unknown kinds from newer servers.
type t =
  | Validation
  | Configuration
  | Thrown
  | Query
  | Serialization
  | NotAllowed
  | NotFound
  | AlreadyExists
  | Connection
  | Internal
  | Raw(string)

@module("surrealdb") @scope("ErrorKind") external validationRaw: string = "Validation"
@module("surrealdb") @scope("ErrorKind") external configurationRaw: string = "Configuration"
@module("surrealdb") @scope("ErrorKind") external thrownRaw: string = "Thrown"
@module("surrealdb") @scope("ErrorKind") external queryRaw: string = "Query"
@module("surrealdb") @scope("ErrorKind") external serializationRaw: string = "Serialization"
@module("surrealdb") @scope("ErrorKind") external notAllowedRaw: string = "NotAllowed"
@module("surrealdb") @scope("ErrorKind") external notFoundRaw: string = "NotFound"
@module("surrealdb") @scope("ErrorKind") external alreadyExistsRaw: string = "AlreadyExists"
@module("surrealdb") @scope("ErrorKind") external connectionRaw: string = "Connection"
@module("surrealdb") @scope("ErrorKind") external internalRaw: string = "Internal"

let validation = Validation
let configuration = Configuration
let thrown = Thrown
let query = Query
let serialization = Serialization
let notAllowed = NotAllowed
let notFound = NotFound
let alreadyExists = AlreadyExists
let connection = Connection
let internal = Internal

let all = [
  validation,
  configuration,
  thrown,
  query,
  serialization,
  notAllowed,
  notFound,
  alreadyExists,
  connection,
  internal,
]

let fromString = value =>
  switch value {
  | value when value == validationRaw => validation
  | value when value == configurationRaw => configuration
  | value when value == thrownRaw => thrown
  | value when value == queryRaw => query
  | value when value == serializationRaw => serialization
  | value when value == notAllowedRaw => notAllowed
  | value when value == notFoundRaw => notFound
  | value when value == alreadyExistsRaw => alreadyExists
  | value when value == connectionRaw => connection
  | value when value == internalRaw => internal
  | raw => Raw(raw)
  }

let toString = value =>
  switch value {
  | Validation => validationRaw
  | Configuration => configurationRaw
  | Thrown => thrownRaw
  | Query => queryRaw
  | Serialization => serializationRaw
  | NotAllowed => notAllowedRaw
  | NotFound => notFoundRaw
  | AlreadyExists => alreadyExistsRaw
  | Connection => connectionRaw
  | Internal => internalRaw
  | Raw(raw) => raw
  }
