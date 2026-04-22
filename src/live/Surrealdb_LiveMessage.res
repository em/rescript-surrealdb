// src/bindings/Surrealdb_LiveMessage.res — SurrealDB live message binding.
// Concern: bind the message objects yielded by a live subscription.
// Source: node_modules/surrealdb/dist/surrealdb.d.ts — LiveMessage has
// queryId, action, recordId, and value.
type t

@get external queryId: t => Surrealdb_Uuid.t = "queryId"
@get external action: t => string = "action"
@get external recordId: t => Surrealdb_RecordId.t = "recordId"
@get external valueRaw: t => unknown = "value"

let value = message =>
  message->valueRaw->Surrealdb_Value.fromUnknown
