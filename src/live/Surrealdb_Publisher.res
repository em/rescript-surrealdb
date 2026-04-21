// src/bindings/Surrealdb_Publisher.res — SurrealDB Publisher binding.
// Concern: bind the exported event publisher utility from the surrealdb SDK.
type t

@module("surrealdb") @new external make: unit => t = "Publisher"

@module("../support/Surrealdb_Interop.js")
external subscribe: (t, string, array<unknown> => unit) => unit => unit = "subscribeEvent"

@module("../support/Surrealdb_Interop.js")
external subscribeFirst: (t, array<string>) => promise<array<unknown>> = "publisherSubscribeFirst"

@module("../support/Surrealdb_Interop.js")
external publish: (t, string, array<unknown>) => unit = "publisherPublish"
