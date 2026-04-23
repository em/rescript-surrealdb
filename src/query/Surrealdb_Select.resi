type t<'value>

let fromTableOn: (Surrealdb_Queryable.t, Surrealdb_Table.t) => t<Surrealdb_Value.t>
let fromRecordIdOn: (Surrealdb_Queryable.t, Surrealdb_RecordId.t) => t<Surrealdb_Value.t>
let fromRangeOn: (Surrealdb_Queryable.t, Surrealdb_RecordIdRange.t) => t<Surrealdb_Value.t>
let tableOn: (Surrealdb_Queryable.t, string) => t<Surrealdb_Value.t>
let recordOn: (Surrealdb_Queryable.t, string, string) => t<Surrealdb_Value.t>
let rangeOn: (Surrealdb_Queryable.t, Surrealdb_RecordIdRange.t) => t<Surrealdb_Value.t>
let table: (Surrealdb_Surreal.t, string) => t<Surrealdb_Value.t>
let record: (Surrealdb_Surreal.t, string, string) => t<Surrealdb_Value.t>
let range: (Surrealdb_Surreal.t, Surrealdb_RecordIdRange.t) => t<Surrealdb_Value.t>
let fields: (t<'value>, array<string>) => t<'value>
let value: (t<'value>, string) => t<'value>
let start: (t<'value>, int) => t<'value>
let limit: (t<'value>, int) => t<'value>
let where: (t<'value>, Surrealdb_Expr.t) => t<'value>
let fetch: (t<'value>, array<string>) => t<'value>
let timeout: (t<'value>, Surrealdb_Duration.t) => t<'value>
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
let resolve: t<Surrealdb_Value.t> => promise<Surrealdb_Value.t>
let resolveJson: t<JSON.t> => promise<JSON.t>
