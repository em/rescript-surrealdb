// src/bindings/Surrealdb_Run.res — SurrealDB RunPromise binding.
// Concern: bind the RunPromise class from the surrealdb SDK.
// Source: node_modules/surrealdb/dist/surrealdb.d.ts — SurrealQueryable.run()
// returns RunPromise with compile() and json().
type t<'value>

@send
external functionNoArgsOn: (Surrealdb_Queryable.t, string) => t<Surrealdb_JsValue.t> = "run"

@send
external functionOn: (
  Surrealdb_Queryable.t,
  string,
  array<Surrealdb_JsValue.t>,
) => t<Surrealdb_JsValue.t> = "run"

@send
external versionedFunctionNoArgsOn: (
  Surrealdb_Queryable.t,
  string,
  string,
) => t<Surrealdb_JsValue.t> = "run"

@send
external versionedFunctionOn: (
  Surrealdb_Queryable.t,
  string,
  string,
  array<Surrealdb_JsValue.t>,
) => t<Surrealdb_JsValue.t> = "run"

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
external json: t<'value> => t<'value> = "json"

@send
external compile: t<'value> => Surrealdb_BoundQuery.t = "compile"

@send
external stream: t<'value> => Surrealdb_AsyncIterable.t<Surrealdb_Frame.t<'value>> = "stream"

@send
external thenResolve: (t<'value>, @uncurry ('value => 'value)) => promise<'value> = "then"

let resolve = promise =>
  promise->thenResolve(value => value)
