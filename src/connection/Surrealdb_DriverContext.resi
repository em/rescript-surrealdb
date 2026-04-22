type t

let makeRaw: (
  ~options: Surrealdb_DriverOptions.t,
  ~uniqueId: unit => string,
  ~codecs: dict<Surrealdb_ValueCodec.t>,
  unit,
) => t
let make: (
  ~options: Surrealdb_DriverOptions.t,
  ~uniqueId: unit => string,
  ~codecs: dict<Surrealdb_ValueCodec.t>,
) => t
let instantiate: (t, Surrealdb_RemoteEngines.factory) => Surrealdb_Engine.t
