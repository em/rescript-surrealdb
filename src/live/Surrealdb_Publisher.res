// src/bindings/Surrealdb_Publisher.res — SurrealDB Publisher binding.
// Concern: bind the exported event publisher utility from the surrealdb SDK.
type t

@module("surrealdb") @new external make: unit => t = "Publisher"

@module("../support/Surrealdb_Interop.js")
external subscribeRaw: (t, string, array<unknown> => unit) => unit => unit = "subscribeEvent"

@module("../support/Surrealdb_Interop.js")
external subscribeFirstRaw: (t, array<string>) => promise<array<unknown>> = "publisherSubscribeFirst"

@module("../support/Surrealdb_Interop.js")
external publishRaw: (t, string, array<Surrealdb_JsValue.t>) => unit = "publisherPublish"

let subscribe = (publisher, event, listener) =>
  publisher->subscribeRaw(event, payload => listener(payload->Array.map(Surrealdb_Value.fromUnknown)))

let subscribeFirst = (publisher, events) =>
  publisher->subscribeFirstRaw(events)->Promise.thenResolve(payload => payload->Array.map(Surrealdb_Value.fromUnknown))

let publish = (publisher, event, payload) =>
  publisher->publishRaw(event, payload)
