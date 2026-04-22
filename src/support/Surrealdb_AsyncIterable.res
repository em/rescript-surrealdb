// src/bindings/Surrealdb_AsyncIterable.res — JavaScript AsyncIterable boundary.
// Concern: consume SDK stream() results from ReScript without narrowing the SDK
// surface to callback-only adapters.
type t<'value>

@module("./Surrealdb_Interop.js")
external collect: t<'value> => promise<array<'value>> = "collectAsync"

@module("./Surrealdb_Interop.js")
external forEach: (t<'value>, 'value => unit) => promise<unit> = "forEachAsync"
