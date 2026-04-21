// src/bindings/Surrealdb_WebSocketEngine.res — SurrealDB WebSocketEngine binding.
// Concern: classify exported WebSocketEngine instances created through the public
// engine-factory surface.
type t
type ctor

external asEngine: t => Surrealdb_Engine.t = "%identity"
external unsafeFromEngine: Surrealdb_Engine.t => t = "%identity"

@module("surrealdb") external ctor: ctor = "WebSocketEngine"

let fromEngine = engine =>
  if JsTypeReflection.instanceOfClass(~instance=engine, ~class_=ctor) {
    Some(unsafeFromEngine(engine))
  } else {
    None
  }
