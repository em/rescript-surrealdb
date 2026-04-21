// src/bindings/Surrealdb_Escape.res — SurrealDB escaping helpers.
// Concern: bind the public helper functions that escape identifiers, numbers,
// record-id parts, and range bounds into SurrealQL-safe text.
@module("surrealdb") external ident: string => string = "escapeIdent"
@module("surrealdb") external int: int => string = "escapeNumber"
@module("surrealdb") external float: float => string = "escapeNumber"
@module("surrealdb") external bigInt: BigInt.t => string = "escapeNumber"
@module("surrealdb") external idPart: unknown => string = "escapeIdPart"
@module("surrealdb") external rangeBoundRaw: unknown => string = "escapeRangeBound"

let rangeBound = bound =>
  bound->Surrealdb_RangeBound.toUnknown->rangeBoundRaw
