// src/bindings/Surrealdb_ErrorKind.res — SurrealDB server error kind constants.
// Concern: bind the exported ErrorKind constants from the surrealdb SDK.
@module("surrealdb") @scope("ErrorKind") external validation: string = "Validation"
@module("surrealdb") @scope("ErrorKind") external configuration: string = "Configuration"
@module("surrealdb") @scope("ErrorKind") external thrown: string = "Thrown"
@module("surrealdb") @scope("ErrorKind") external query: string = "Query"
@module("surrealdb") @scope("ErrorKind") external serialization: string = "Serialization"
@module("surrealdb") @scope("ErrorKind") external notAllowed: string = "NotAllowed"
@module("surrealdb") @scope("ErrorKind") external notFound: string = "NotFound"
@module("surrealdb") @scope("ErrorKind") external alreadyExists: string = "AlreadyExists"
@module("surrealdb") @scope("ErrorKind") external connection: string = "Connection"
@module("surrealdb") @scope("ErrorKind") external internal: string = "Internal"

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
