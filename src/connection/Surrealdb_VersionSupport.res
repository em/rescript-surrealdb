// src/bindings/Surrealdb_VersionSupport.res — SurrealDB SDK version support helpers.
// Concern: bind the exported minimum/maximum compatibility constants and predicate.
@module("surrealdb") external minimumVersion: string = "MINIMUM_VERSION"
@module("surrealdb") external maximumVersion: string = "MAXIMUM_VERSION"

@module("surrealdb")
external isVersionSupportedRaw: (~version: string, ~minimum: string=?, ~until: string=?) => bool = "isVersionSupported"

let isVersionSupported = (version, ~minimum=?, ~until=?) =>
  isVersionSupportedRaw(~version, ~minimum?, ~until?)
