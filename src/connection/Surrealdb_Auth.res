// src/bindings/Surrealdb_Auth.res — SurrealDB auth-query binding.
// Concern: bind the AuthPromise returned by SurrealQueryable.auth().
// Source: surrealdb.d.ts — AuthPromise exposes .json(), .compile(), and .stream().
type t<'value>

@send
external json: t<'value> => t<'value> = "json"

@send
external compile: t<'value> => Surrealdb_BoundQuery.t = "compile"

@send
external stream: t<'value> => Surrealdb_AsyncIterable.t<Surrealdb_Frame.t<'value>> = "stream"

@send
external thenResolve: (t<'value>, @uncurry ('value => 'value)) => promise<'value> = "then"

let resolve = promise =>
  promise->thenResolve(value => value)
