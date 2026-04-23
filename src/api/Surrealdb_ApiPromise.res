// src/bindings/Surrealdb_ApiPromise.res — SurrealDB ApiPromise binding.
// Concern: bind ApiPromise with explicit response/body and value/JSON state.
// Source: surrealdb.d.ts — ApiPromise<Req, Res, V, J> tracks both envelope mode
// and JSON mode in the public SDK.
// Boundary: default API calls resolve to `Surrealdb_ApiResponse.t`; `.value()`
// switches to body mode; `.json()` switches payload format to JSON mode.
// Why this shape: the API builder has two real upstream state dimensions, so one
// public `'value` parameter is not an honest model.
// Coverage: tests/connection/SurrealdbSessionSurface_test.res.
type responseMode
type bodyMode
type valueFormat
type jsonFormat
type t<'mode, 'format>

@send external json: t<'mode, valueFormat> => t<'mode, jsonFormat> = "json"
@send external header: (t<'mode, 'format>, string, string) => t<'mode, 'format> = "header"
@send external query: (t<'mode, 'format>, string, string) => t<'mode, 'format> = "query"
@send external value: t<responseMode, 'format> => t<bodyMode, 'format> = "value"
@send external compile: t<'mode, 'format> => Surrealdb_BoundQuery.t = "compile"
@send external stream: t<'mode, valueFormat> => Surrealdb_AsyncIterable.t<Surrealdb_Frame.t<Surrealdb_ApiResponse.t>> = "stream"
@send external streamJson: t<'mode, jsonFormat> => Surrealdb_AsyncIterable.t<Surrealdb_Frame.t<Surrealdb_ApiJsonResponse.t>> = "stream"

@send
external then_: (
  t<responseMode, valueFormat>,
  @uncurry (Surrealdb_ApiResponse.t => Surrealdb_ApiResponse.t),
) => promise<Surrealdb_ApiResponse.t> = "then"

@send
external thenJsonRaw: (
  t<responseMode, jsonFormat>,
  @uncurry (Surrealdb_ApiJsonResponse.t => Surrealdb_ApiJsonResponse.t),
) => promise<Surrealdb_ApiJsonResponse.t> = "then"

@send
external thenValueRaw: (t<bodyMode, valueFormat>, @uncurry (unknown => unknown)) => promise<unknown> = "then"

@send
external thenValueJsonRaw: (t<bodyMode, jsonFormat>, @uncurry (JSON.t => JSON.t)) => promise<JSON.t> = "then"

let resolve = apiPromise =>
  apiPromise->then_(value => value)

let resolveJson = apiPromise =>
  apiPromise->thenJsonRaw(value => value)

let awaitValue = apiPromise =>
  apiPromise->thenValueRaw(value => value)->Promise.thenResolve(Surrealdb_Value.fromUnknown)

let awaitValueJson = apiPromise =>
  apiPromise->thenValueJsonRaw(value => value)

let thenJson = (apiPromise, callback) =>
  apiPromise->resolveJson->Promise.thenResolve(callback)

let thenValue = (apiPromise, callback) =>
  apiPromise->awaitValue->Promise.thenResolve(callback)

let thenValueJson = (apiPromise, callback) =>
  apiPromise->awaitValueJson->Promise.thenResolve(callback)
