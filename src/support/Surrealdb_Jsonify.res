// src/bindings/Surrealdb_Jsonify.res — SurrealDB JSON transport conversion.
// Concern: bind the public SDK function that converts typed SDK values into their
// JSON transport representation.
@module("surrealdb") external valueRaw: Surrealdb_JsValue.t => unknown = "jsonify"
external jsonFromUnknown: unknown => JSON.t = "%identity"

let value = input =>
  input->valueRaw->jsonFromUnknown
