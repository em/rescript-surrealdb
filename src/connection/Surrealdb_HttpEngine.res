// src/bindings/Surrealdb_HttpEngine.res — SurrealDB HttpEngine binding.
// Concern: classify exported HttpEngine instances created through the public
// engine-factory surface.
type t
type ctor

external asEngine: t => Surrealdb_Engine.t = "%identity"
external unsafeFromEngine: Surrealdb_Engine.t => t = "%identity"

@module("surrealdb") external ctor: ctor = "HttpEngine"

let fromEngine = engine =>
  if JsTypeReflection.instanceOfClass(~instance=engine, ~class_=ctor) {
    Some(unsafeFromEngine(engine))
  } else {
    None
  }
