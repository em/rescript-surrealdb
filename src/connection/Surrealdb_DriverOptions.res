// src/bindings/Surrealdb_DriverOptions.res — SurrealDB driver option binding.
// Concern: model the public driver options object separately from the Surreal
// client module so engine-factory typing does not create a module cycle.
type t
type websocketImpl
type fetchImpl

@obj
external makeRaw: (
  ~engines: Surrealdb_RemoteEngines.t=?,
  ~codecs: dict<Surrealdb_ValueCodec.factory>=?,
  ~codecOptions: Surrealdb_CborCodec.options=?,
  ~websocketImpl: websocketImpl=?,
  ~fetchImpl: fetchImpl=?,
  unit,
) => t = ""

let make = (~engines=?, ~codecs=?, ~codecOptions=?, ~websocketImpl=?, ~fetchImpl=?, ()) =>
  makeRaw(~engines?, ~codecs?, ~codecOptions?, ~websocketImpl?, ~fetchImpl?, ())
