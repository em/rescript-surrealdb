// src/bindings/Surrealdb_Auth.res — SurrealDB auth-query binding.
// Concern: bind AuthPromise with explicit classified-value and JSON-result modes.
// Source: surrealdb.d.ts — AuthPromise<T, J> resolves to `MaybeJsonify<T, J>`.
// Boundary: configuration uses SDK input bindings, while `resolve` and `stream`
// expose classified `Surrealdb_Value.t` payloads or explicit JSON-mode payloads
// after `.json()`.
// Why this shape: auth execution does not preserve a caller-chosen payload type,
// but JSON mode is a real upstream state transition.
// Coverage: tests/connection/SurrealdbSessionSurface_test.res.
type t<'value>

@send
external json: t<'value> => t<JSON.t> = "json"

@send
external compile: t<'value> => Surrealdb_BoundQuery.t = "compile"

@send
external streamRaw: t<'value> => Surrealdb_AsyncIterable.t<Surrealdb_Frame.t<unknown>> = "stream"

@send
external thenRaw: (t<'value>, @uncurry (unknown => unknown)) => promise<unknown> = "then"

external asQueryFrameStream: Surrealdb_AsyncIterable.t<Surrealdb_Frame.t<unknown>> => Surrealdb_AsyncIterable.t<Surrealdb_QueryFrame.t> = "%identity"
external asJsonFrameStream: Surrealdb_AsyncIterable.t<Surrealdb_Frame.t<unknown>> => Surrealdb_AsyncIterable.t<Surrealdb_JsonFrame.t> = "%identity"
external jsonFromUnknown: unknown => JSON.t = "%identity"

let stream = promise =>
  promise->streamRaw->asQueryFrameStream

let streamJson = promise =>
  promise->streamRaw->asJsonFrameStream

let resolve = promise =>
  promise->thenRaw(value => value)->Promise.thenResolve(Surrealdb_Value.fromUnknown)

let resolveJson = promise =>
  promise->thenRaw(value => value)->Promise.thenResolve(jsonFromUnknown)

let thenResolve = (promise, callback) =>
  promise->resolve->Promise.thenResolve(callback)

let thenResolveJson = (promise, callback) =>
  promise->resolveJson->Promise.thenResolve(callback)
