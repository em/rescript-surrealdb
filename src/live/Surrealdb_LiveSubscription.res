// src/bindings/Surrealdb_LiveSubscription.res — SurrealDB live subscription binding.
// Concern: bind the live subscription object returned by managed and unmanaged
// live queries.
// Source: node_modules/surrealdb/dist/surrealdb.d.ts — LiveSubscription exposes
// id, isManaged, resource, isAlive, kill(), and subscribe().
type t

@get external id: t => Surrealdb_Uuid.t = "id"
@get external isManaged: t => bool = "isManaged"
@return(nullable) @get external resource: t => option<Surrealdb_Table.t> = "resource"
@get external isAlive: t => bool = "isAlive"

@send external kill: t => promise<unit> = "kill"
@send external subscribe: (t, Surrealdb_LiveMessage.t => unit) => unit => unit = "subscribe"
