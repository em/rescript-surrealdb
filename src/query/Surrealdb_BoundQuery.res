// src/bindings/Surrealdb_BoundQuery.res — SurrealDB BoundQuery binding.
// Concern: bind the BoundQuery class from the surrealdb SDK.
// Source: surrealdb.d.ts — BoundQuery<R> combines a query string with bindings.
// Supports append for chaining multiple queries. Template literal tagging
// auto-stores interpolated values as bindings.
type t

@module("surrealdb") @new external make: unit => t = "BoundQuery"
@module("surrealdb") @new external fromText: string => t = "BoundQuery"
@module("surrealdb") @new external fromQuery: (string, dict<Surrealdb_JsValue.t>) => t = "BoundQuery"
@module("surrealdb") @new external clone: t => t = "BoundQuery"
@module("surrealdb")
external mergeBindings: (dict<Surrealdb_JsValue.t>, dict<Surrealdb_JsValue.t>) => unit = "mergeBindings"

@send external appendQuery: (t, t) => t = "append"
@send external appendText: (t, string) => t = "append"
@send external appendString: (t, string, dict<Surrealdb_JsValue.t>) => t = "append"
@send @variadic external appendTemplate: (t, array<string>, array<unknown>) => t = "append"

@get external query: t => string = "query"
@get external bindings: t => dict<Surrealdb_JsValue.t> = "bindings"
