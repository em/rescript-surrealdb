// src/bindings/Surrealdb_DriverContext.res — SurrealDB driver-context binding.
// Concern: model the public DriverContext shape consumed by exported engine
// factories without inventing private constructors or hidden state.
// Source: node_modules/surrealdb/dist/surrealdb.d.ts — DriverContext is the
// object passed into EngineFactory functions.
// Boundary: package-authored constructor around an upstream function-valued record.
// Why this shape: Remote engine factories stay opaque so DriverOptions can
// accept the upstream engines object without reintroducing a module cycle.
// Coverage: tests/query/SurrealdbPublicSurface_test.res
type t

@module("../support/Surrealdb_Interop.js")
external instantiateRaw: (t, Surrealdb_RemoteEngines.factory) => Surrealdb_Engine.t =
  "callEngineFactory"

@obj
external makeRawInternal: (
  ~options: Surrealdb_DriverOptions.t,
  ~uniqueId: unit => string,
  ~codecs: dict<Surrealdb_ValueCodec.t>,
  unit,
) => t = ""

let makeRaw = (~options, ~uniqueId, ~codecs, ()) =>
  makeRawInternal(~options, ~uniqueId, ~codecs, ())

let make = (~options, ~uniqueId, ~codecs) =>
  makeRaw(~options, ~uniqueId, ~codecs, ())

let instantiate = (context, factory) =>
  instantiateRaw(context, factory)
