// src/bindings/Surrealdb_RpcEngine.res — SurrealDB RpcEngine binding.
// Concern: classify exported RpcEngine instances so the JSON transport layer is
// visible as a first-class public SDK surface.
type t
type ctor

external asEngine: t => Surrealdb_Engine.t = "%identity"
external unsafeFromEngine: Surrealdb_Engine.t => t = "%identity"

@module("surrealdb") external ctor: ctor = "RpcEngine"

@send external version: t => promise<Surrealdb_VersionInfo.t> = "version"
@send external sessions: t => promise<array<Surrealdb_Uuid.t>> = "sessions"

let fromEngine = engine =>
  if JsTypeReflection.instanceOfClass(~instance=engine, ~class_=ctor) {
    Some(unsafeFromEngine(engine))
  } else {
    None
  }
