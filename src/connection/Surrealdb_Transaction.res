// src/bindings/Surrealdb_Transaction.res — SurrealDB transaction binding.
// Concern: bind the SurrealTransaction class from the surrealdb SDK.
// Source: https://surrealdb.com/docs/sdk/javascript/concepts/transactions —
// transactions share the SurrealQueryable surface until commit() or cancel().
type t

external asQueryable: t => Surrealdb_Queryable.t = "%identity"

@send external commit: t => promise<unit> = "commit"
@send external cancel: t => promise<unit> = "cancel"
