// src/bindings/Surrealdb_ApiPromise.res — SurrealDB ApiPromise binding.
// Concern: bind the ApiPromise class from the surrealdb SDK.
// Source: https://surrealdb.com/docs/languages/javascript/concepts/invoking-apis —
// ApiPromise supports request headers, query params, value/json response shaping,
// and compile() for BoundQuery generation.
type t<'value>

@send external json: t<'value> => t<unknown> = "json"
@send external header: (t<'value>, string, string) => t<'value> = "header"
@send external query: (t<'value>, string, string) => t<'value> = "query"
@send external value: t<'value> => t<unknown> = "value"
@send external compile: t<'value> => Surrealdb_BoundQuery.t = "compile"
@send external stream: t<'value> => Surrealdb_AsyncIterable.t<Surrealdb_Frame.t<Surrealdb_ApiResponse.t>> = "stream"

@send
external then_: (t<'value>, @uncurry ('value => 'value)) => promise<'value> = "then"

let resolve = apiPromise =>
  apiPromise->then_(value => value)

let awaitValue = apiPromise =>
  apiPromise->resolve
