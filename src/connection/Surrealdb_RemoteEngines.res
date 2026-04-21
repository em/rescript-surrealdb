// src/bindings/Surrealdb_RemoteEngines.res — SurrealDB remote-engine helpers.
// Concern: bind the public SDK helpers used to configure remote engines and
// diagnostic wrapping without constructing internal engine contexts manually.
type t
type factory = unknown => Surrealdb_Engine.t

external asDict: t => dict<factory> = "%identity"

@module("surrealdb") external create: unit => t = "createRemoteEngines"
@module("surrealdb") external applyDiagnostics: (t, unknown => unit) => t = "applyDiagnostics"

@get external ws: t => factory = "ws"
@get external wss: t => factory = "wss"
@get external http: t => factory = "http"
@get external https: t => factory = "https"

let instantiate = (factory, context) =>
  factory(context)

let keys = engines =>
  engines->asDict->Dict.toArray->Array.map(((key, _value)) => key)
