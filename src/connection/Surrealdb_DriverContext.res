// src/bindings/Surrealdb_DriverContext.res — SurrealDB driver-context binding.
// Concern: model the public DriverContext shape consumed by exported engine
// factories without inventing private constructors or hidden state.
type t

external toUnknown: t => unknown = "%identity"

@obj
external makeRaw: (
  ~options: Surrealdb_Surreal.driverOptions,
  ~uniqueId: unit => string,
  ~codecs: dict<Surrealdb_ValueCodec.t>,
  unit,
) => t = ""

let make = (~options, ~uniqueId, ~codecs) =>
  makeRaw(~options, ~uniqueId, ~codecs, ())
