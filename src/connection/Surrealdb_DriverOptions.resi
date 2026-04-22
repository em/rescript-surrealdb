type t
type websocketImpl
type fetchImpl

let make: (
  ~engines: Surrealdb_RemoteEngines.t=?,
  ~codecs: dict<Surrealdb_ValueCodec.factory>=?,
  ~codecOptions: Surrealdb_CborCodec.options=?,
  ~websocketImpl: websocketImpl=?,
  ~fetchImpl: fetchImpl=?,
  unit,
) => t
