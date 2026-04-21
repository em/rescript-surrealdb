// src/bindings/Surrealdb_Expr.res — SurrealDB expression builder bindings.
// Concern: bind the expression builder functions from the surrealdb SDK.
// Source: surrealdb.d.ts — Expression builders for composing WHERE conditions.
// Each returns an Expr that can be combined with and/or/not.
type t

// Source: surrealdb.d.ts — raw(s) creates a raw SurrealQL expression. IMPORTANT:
// incorrect use risks SQL injection. Only use when no other operator is applicable.
@module("surrealdb") external raw: string => t = "raw"

// Source: surrealdb.d.ts — Comparison operators
@module("surrealdb") external eq: (string, unknown) => t = "eq"
@module("surrealdb") external eeq: (string, unknown) => t = "eeq"
@module("surrealdb") external ne: (string, unknown) => t = "ne"
@module("surrealdb") external gt: (string, unknown) => t = "gt"
@module("surrealdb") external gte: (string, unknown) => t = "gte"
@module("surrealdb") external lt: (string, unknown) => t = "lt"
@module("surrealdb") external lte: (string, unknown) => t = "lte"

// Source: surrealdb.d.ts — Collection operators
@module("surrealdb") external contains: (string, unknown) => t = "contains"
@module("surrealdb") external containsAny: (string, unknown) => t = "containsAny"
@module("surrealdb") external containsAll: (string, unknown) => t = "containsAll"
@module("surrealdb") external containsNone: (string, unknown) => t = "containsNone"
@module("surrealdb") external inside: (string, unknown) => t = "inside"
@module("surrealdb") external outside: (string, unknown) => t = "outside"
@module("surrealdb") external intersects: (string, unknown) => t = "intersects"

// Source: surrealdb.d.ts — Full-text search and vector operators
@module("surrealdb") external matches: (string, string) => t = "matches"
@module("surrealdb") external matchesWithRef: (string, string, int) => t = "matches"
@module("surrealdb") external knn: (string, unknown, int) => t = "knn"
@module("surrealdb") external knnWithMetric: (string, unknown, int, string) => t = "knn"
@module("surrealdb") external knnWithEf: (string, unknown, int, int) => t = "knn"
@module("surrealdb") external between: (string, unknown, unknown) => t = "between"

// Source: surrealdb.d.ts — Logical combinators
@module("surrealdb") @variadic external and_: array<t> => t = "and"
@module("surrealdb") @variadic external or_: array<t> => t = "or"
@module("surrealdb") external not_: t => t = "not"

// Source: surrealdb.d.ts — expr(ExprLike) converts an expression-like value to BoundQuery
@module("surrealdb") external toBoundQuery: t => Surrealdb_BoundQuery.t = "expr"
