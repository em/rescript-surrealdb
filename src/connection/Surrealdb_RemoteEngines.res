// src/bindings/Surrealdb_RemoteEngines.res — SurrealDB remote-engine configuration API.
// Concern: bind the public SDK functions used to configure remote engines and
// diagnostic wrapping without constructing internal engine contexts manually.
// Source: node_modules/surrealdb/dist/surrealdb.d.ts — createRemoteEngines()
// and applyDiagnostics() both operate on Engines, a string-keyed record of
// EngineFactory functions.
// Boundary: package-owned opaque view over the SDK Engines dictionary.
// Why this shape: the returned object is a plain JS record whose values are
// callable engine factories, so the binding keeps factory values opaque and
// leaves typed invocation to Surrealdb_DriverContext.instantiate.
// Coverage: tests/query/SurrealdbPublicSurface_test.res,
// tests/connection/SurrealdbSessionSurface_test.res
type t
type factory

external asDict: t => dict<factory> = "%identity"

@module("surrealdb") external create: unit => t = "createRemoteEngines"
@module("surrealdb") external applyDiagnosticsRaw: (t, unknown => unit) => t = "applyDiagnostics"

@get external ws: t => factory = "ws"
@get external wss: t => factory = "wss"
@get external http: t => factory = "http"
@get external https: t => factory = "https"

let applyDiagnostics = (engines, listener) =>
  engines->applyDiagnosticsRaw(event => listener(event->Surrealdb_Value.fromUnknown))

let keys = engines =>
  engines->asDict->Dict.toArray->Array.map(((key, _value)) => key)
