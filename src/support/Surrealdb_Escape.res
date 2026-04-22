// src/bindings/Surrealdb_Escape.res — SurrealDB escaping functions.
// Concern: bind the public functions that escape identifiers, numbers,
// record-id parts, and range bounds into SurrealQL-safe text.
@module("surrealdb") external ident: string => string = "escapeIdent"
@module("surrealdb") external int: int => string = "escapeNumber"
@module("surrealdb") external float: float => string = "escapeNumber"
@module("surrealdb") external bigInt: BigInt.t => string = "escapeNumber"
@module("surrealdb") external idPart: Surrealdb_JsValue.t => string = "escapeIdPart"
@module("surrealdb") external rangeBoundRaw: unknown => string = "escapeRangeBound"
external boundToUnknown: Surrealdb_RangeBound.t => unknown = "%identity"

let rangeBound = bound =>
  bound->boundToUnknown->rangeBoundRaw
