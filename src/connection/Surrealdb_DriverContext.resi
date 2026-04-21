type t

let toUnknown: t => unknown
let makeRaw: (
  ~options: Surrealdb_Surreal.driverOptions,
  ~uniqueId: unit => string,
  ~codecs: dict<Surrealdb_ValueCodec.t>,
  unit,
) => t
let make: (
  ~options: Surrealdb_Surreal.driverOptions,
  ~uniqueId: unit => string,
  ~codecs: dict<Surrealdb_ValueCodec.t>,
) => t
