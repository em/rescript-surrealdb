// src/bindings/Surrealdb_Queryable.res — SurrealDB queryable base binding.
// Concern: represent the shared SurrealQueryable base class implemented by Surreal,
// SurrealSession, and SurrealTransaction.
// Source: https://surrealdb.com/docs/sdk/javascript/api/core/surreal-queryable —
// query, select, create, update, delete, live, run, and api live on the shared
// queryable layer, not only on the root client.
type t

@send
external authOn: t => Surrealdb_Auth.t<Surrealdb_JsValue.t> = "auth"

let auth = queryable =>
  queryable->authOn
