type t<'value>

let fromRecordIdOn: (Surrealdb_Queryable.t, Surrealdb_RecordId.t) => t<Surrealdb_JsValue.t>
let fromTableOn: (Surrealdb_Queryable.t, Surrealdb_Table.t) => t<Surrealdb_JsValue.t>
let fromRangeOn: (Surrealdb_Queryable.t, Surrealdb_RecordIdRange.t) => t<Surrealdb_JsValue.t>
let recordOn: (Surrealdb_Queryable.t, string, string) => t<Surrealdb_JsValue.t>
let tableOn: (Surrealdb_Queryable.t, string) => t<Surrealdb_JsValue.t>
let rangeOn: (Surrealdb_Queryable.t, Surrealdb_RecordIdRange.t) => t<Surrealdb_JsValue.t>
let fromRecordId: (Surrealdb_Surreal.t, Surrealdb_RecordId.t) => t<Surrealdb_JsValue.t>
let fromTable: (Surrealdb_Surreal.t, Surrealdb_Table.t) => t<Surrealdb_JsValue.t>
let fromRange: (Surrealdb_Surreal.t, Surrealdb_RecordIdRange.t) => t<Surrealdb_JsValue.t>
let outputRaw: (t<'value>, string) => t<'value>
let timeout: (t<'value>, Surrealdb_Duration.t) => t<'value>
let version: (t<'value>, Surrealdb_DateTime.t) => t<'value>
let json: t<'value> => t<'value>
let compile: t<'value> => Surrealdb_BoundQuery.t
let stream: t<'value> => Surrealdb_AsyncIterable.t<Surrealdb_Frame.t<'value>>
let thenResolve: (t<'value>, ('value => 'value)) => promise<'value>
let output: (t<'value>, Surrealdb_Output.t) => t<'value>
let resolve: t<'value> => promise<'value>
