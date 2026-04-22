// src/bindings/Surrealdb_Surql.res — SurrealQL literal tagged templates.
// Concern: bind the public tagged-template and formatting functions that the SDK
// exports for building SurrealQL strings, typed literals, and BoundQuery values.
@module("surrealdb") @variadic external text: (array<string>, array<Surrealdb_JsValue.t>) => string = "s"
@module("surrealdb") @variadic external dateTime: (array<string>, array<Surrealdb_JsValue.t>) => Surrealdb_DateTime.t = "d"
@module("surrealdb") @variadic external recordId: (array<string>, array<Surrealdb_JsValue.t>) => Surrealdb_StringRecordId.t = "r"
@module("surrealdb") @variadic external uuid: (array<string>, array<Surrealdb_JsValue.t>) => Surrealdb_Uuid.t = "u"
@module("surrealdb") @variadic external query: (array<string>, array<Surrealdb_JsValue.t>) => Surrealdb_BoundQuery.t = "surql"
@module("surrealdb") external toString: Surrealdb_JsValue.t => string = "toSurqlString"
@module("surrealdb") external toSurrealqlString: Surrealdb_JsValue.t => string = "toSurrealqlString"
