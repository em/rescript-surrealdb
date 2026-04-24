type t<'value>

let fromRecordIdOn: (Surrealdb_Queryable.t, Surrealdb_RecordId.t) => t<Surrealdb_Value.t>
let fromTableOn: (Surrealdb_Queryable.t, Surrealdb_Table.t) => t<Surrealdb_Value.t>
let fromRangeOn: (Surrealdb_Queryable.t, Surrealdb_RecordIdRange.t) => t<Surrealdb_Value.t>
let recordOn: (Surrealdb_Queryable.t, string, string) => t<Surrealdb_Value.t>
let tableOn: (Surrealdb_Queryable.t, string) => t<Surrealdb_Value.t>
let rangeOn: (Surrealdb_Queryable.t, Surrealdb_RecordIdRange.t) => t<Surrealdb_Value.t>
let fromRecordId: (Surrealdb_Surreal.t, Surrealdb_RecordId.t) => t<Surrealdb_Value.t>
let fromTable: (Surrealdb_Surreal.t, Surrealdb_Table.t) => t<Surrealdb_Value.t>
let fromRange: (Surrealdb_Surreal.t, Surrealdb_RecordIdRange.t) => t<Surrealdb_Value.t>
let version: (t<'value>, Surrealdb_DateTime.t) => t<'value>
let json: t<'value> => t<JSON.t>
let compile: t<'value> => Surrealdb_BoundQuery.t
let stream: t<Surrealdb_Value.t> => Surrealdb_AsyncIterable.t<Surrealdb_QueryFrame.t>
let streamJson: t<JSON.t> => Surrealdb_AsyncIterable.t<Surrealdb_JsonFrame.t>
let thenResolve: (
  t<Surrealdb_Value.t>,
  (Surrealdb_Value.t => Surrealdb_Value.t),
) => promise<Surrealdb_Value.t>
let thenResolveJson: (t<JSON.t>, (JSON.t => JSON.t)) => promise<JSON.t>
let output: (t<'value>, Surrealdb_Output.t) => t<'value>
let resolve: t<Surrealdb_Value.t> => promise<Surrealdb_Value.t>
let resolveJson: t<JSON.t> => promise<JSON.t>
