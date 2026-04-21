// src/bindings/Surrealdb_VersionInfo.res — SurrealDB version-info binding.
// Concern: bind the version payload returned by the SDK's version() methods.
type t

@get external version: t => string = "version"
