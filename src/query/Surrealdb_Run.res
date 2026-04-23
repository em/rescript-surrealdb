// src/bindings/Surrealdb_Run.res — SurrealDB RunPromise binding.
// Concern: bind RunPromise with explicit classified-value and JSON-result modes.
// Source: surrealdb.d.ts — RunPromise<T, J> resolves to `MaybeJsonify<T, J>`.
// Boundary: routine input arguments stay in SDK input binding types; resolve and
// stream expose classified `Surrealdb_Value.t` or explicit JSON-mode payloads.
// Why this shape: run execution does not preserve a caller-chosen payload
// generic, but JSON mode is a real upstream state transition.
// Coverage: tests/connection/SurrealdbSessionSurface_test.res.
type t<'value>

@send
external functionNoArgsOn: (Surrealdb_Queryable.t, string) => t<Surrealdb_Value.t> = "run"

@send
external functionOn: (
  Surrealdb_Queryable.t,
  string,
  array<Surrealdb_JsValue.t>,
) => t<Surrealdb_Value.t> = "run"

@send
external versionedFunctionNoArgsOn: (
  Surrealdb_Queryable.t,
  string,
  string,
) => t<Surrealdb_Value.t> = "run"

@send
external versionedFunctionOn: (
  Surrealdb_Queryable.t,
  string,
  string,
  array<Surrealdb_JsValue.t>,
) => t<Surrealdb_Value.t> = "run"

let callOn = (queryable, name, ~args=?, ()) =>
  switch args {
  | Some(value) => queryable->functionOn(name, value)
  | None => queryable->functionNoArgsOn(name)
  }

let callVersionedOn = (queryable, name, version, ~args=?, ()) =>
  switch args {
  | Some(value) => queryable->versionedFunctionOn(name, version, value)
  | None => queryable->versionedFunctionNoArgsOn(name, version)
  }

let function_ = (db, name, ~args=?, ()) =>
  db->Surrealdb_Surreal.asQueryable->callOn(name, ~args?, ())

let versionedFunction = (db, name, version, ~args=?, ()) =>
  db->Surrealdb_Surreal.asQueryable->callVersionedOn(name, version, ~args?, ())

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
