// src/bindings/Surrealdb_Surql.res — SurrealQL literal helpers.
// Concern: bind the public tagged-template and formatting helpers that the SDK
// exports for building SurrealQL strings, typed literals, and BoundQuery values.
@module("surrealdb") @variadic external text: (array<string>, array<unknown>) => string = "s"
@module("surrealdb") @variadic external dateTime: (array<string>, array<unknown>) => Surrealdb_DateTime.t = "d"
@module("surrealdb") @variadic external recordId: (array<string>, array<unknown>) => Surrealdb_StringRecordId.t = "r"
@module("surrealdb") @variadic external uuid: (array<string>, array<unknown>) => Surrealdb_Uuid.t = "u"
@module("surrealdb") @variadic external query: (array<string>, array<unknown>) => Surrealdb_BoundQuery.t = "surql"
@module("surrealdb") external toString: unknown => string = "toSurqlString"
@module("surrealdb") external toSurrealqlString: unknown => string = "toSurrealqlString"
