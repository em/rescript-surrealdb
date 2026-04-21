// src/bindings/Surrealdb_Jsonify.res — SurrealDB JSON transport helper.
// Concern: bind the public SDK helper that converts typed SDK values into their
// JSON transport representation.
@module("surrealdb") external value: unknown => unknown = "jsonify"
