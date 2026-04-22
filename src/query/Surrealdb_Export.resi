type sqlPromise<'value>
type modelPromise<'value>
type sqlOptions

type tableFilter =
  | AllTables(bool)
  | OnlyTables(array<string>)

let exportDefault: Surrealdb_Surreal.t => sqlPromise<string>
let exportRaw: (Surrealdb_Surreal.t, sqlOptions) => sqlPromise<string>
let exportModelRaw: (Surrealdb_Surreal.t, string, string) => modelPromise<Js.TypedArray2.Uint8Array.t>
let rawSql: sqlPromise<'value> => sqlPromise<Webapi.Fetch.Response.t>
let rawModel: modelPromise<'value> => modelPromise<Webapi.Fetch.Response.t>
let thenSql: (sqlPromise<'value>, ('value => 'value)) => promise<'value>
let thenModel: (modelPromise<'value>, ('value => 'value)) => promise<'value>
let sqlOptions: (
  ~users: bool=?,
  ~accesses: bool=?,
  ~params: bool=?,
  ~functions: bool=?,
  ~analyzers: bool=?,
  ~apis: bool=?,
  ~buckets: bool=?,
  ~modules: bool=?,
  ~configs: bool=?,
  ~tables: tableFilter=?,
  ~versions: bool=?,
  ~records: bool=?,
  ~sequences: bool=?,
  ~v3: bool=?,
  unit,
) => sqlOptions
let exportSqlDefault: Surrealdb_Surreal.t => sqlPromise<string>
let exportSql: (Surrealdb_Surreal.t, sqlOptions) => sqlPromise<string>
let exportModel: (Surrealdb_Surreal.t, string, string) => modelPromise<Js.TypedArray2.Uint8Array.t>
let awaitSql: sqlPromise<'value> => promise<'value>
let awaitModel: modelPromise<'value> => promise<'value>
