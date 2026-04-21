// src/bindings/Surrealdb_Export.res — SurrealDB export binding.
// Concern: bind ExportPromise and ExportModelPromise from the surrealdb SDK.
// Source: https://surrealdb.com/docs/sdk/javascript/methods/export — db.export()
// returns a SurrealQL string by default, and the installed SDK adds .raw() to
// return a Response directly for stream handling.
type sqlPromise<'value>
type modelPromise<'value>
type sqlOptions

type tableFilter =
  | AllTables(bool)
  | OnlyTables(array<string>)

external unsafeBoolToUnknown: bool => unknown = "%identity"
external unsafeArrayToUnknown: array<string> => unknown = "%identity"

let tableFilterToUnknown = filter =>
  switch filter {
  | AllTables(value) => unsafeBoolToUnknown(value)
  | OnlyTables(value) => unsafeArrayToUnknown(value)
  }

@obj
external makeSqlOptionsRaw: (
  ~users: bool=?,
  ~accesses: bool=?,
  ~params: bool=?,
  ~functions: bool=?,
  ~analyzers: bool=?,
  ~apis: bool=?,
  ~buckets: bool=?,
  ~modules: bool=?,
  ~configs: bool=?,
  ~tables: unknown=?,
  ~versions: bool=?,
  ~records: bool=?,
  ~sequences: bool=?,
  ~v3: bool=?,
  unit,
) => sqlOptions = ""

@send external exportDefault: Surrealdb_Surreal.t => sqlPromise<string> = "export"
@send external exportRaw: (Surrealdb_Surreal.t, sqlOptions) => sqlPromise<string> = "export"
@send external exportModelRaw: (
  Surrealdb_Surreal.t,
  string,
  string,
) => modelPromise<Js.TypedArray2.Uint8Array.t> = "exportModel"

@send external rawSql: sqlPromise<'value> => sqlPromise<Webapi.Fetch.Response.t> = "raw"
@send external rawModel: modelPromise<'value> => modelPromise<Webapi.Fetch.Response.t> = "raw"

@send
external thenSql: (sqlPromise<'value>, @uncurry ('value => 'value)) => promise<'value> = "then"

@send
external thenModel: (modelPromise<'value>, @uncurry ('value => 'value)) => promise<'value> = "then"

let sqlOptions = (
  ~users=?,
  ~accesses=?,
  ~params=?,
  ~functions=?,
  ~analyzers=?,
  ~apis=?,
  ~buckets=?,
  ~modules=?,
  ~configs=?,
  ~tables=?,
  ~versions=?,
  ~records=?,
  ~sequences=?,
  ~v3=?,
  (),
) => {
  let rawTables =
    switch tables {
    | Some(value) => Some(tableFilterToUnknown(value))
    | None => None
    }
  makeSqlOptionsRaw(
    ~users?,
    ~accesses?,
    ~params?,
    ~functions?,
    ~analyzers?,
    ~apis?,
    ~buckets?,
    ~modules?,
    ~configs?,
    ~tables=?rawTables,
    ~versions?,
    ~records?,
    ~sequences?,
    ~v3?,
    (),
  )
}

let exportSqlDefault = db =>
  db->exportDefault

let exportSql = (db, options) =>
  db->exportRaw(options)

let exportModel = (db, name, version) =>
  db->exportModelRaw(name, version)

let awaitSql = promise =>
  promise->thenSql(value => value)

let awaitModel = promise =>
  promise->thenModel(value => value)
