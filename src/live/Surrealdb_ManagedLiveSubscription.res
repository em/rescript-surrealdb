// src/bindings/Surrealdb_ManagedLiveSubscription.res — managed live subscription binding.
// Concern: classify the exported ManagedLiveSubscription subclass without
// narrowing the common live-subscription surface.
type t
type ctor

external asLiveSubscription: t => Surrealdb_LiveSubscription.t = "%identity"
external unsafeFromSubscription: Surrealdb_LiveSubscription.t => t = "%identity"

@module("surrealdb") external ctor: ctor = "ManagedLiveSubscription"

let fromSubscription = subscription =>
  if JsTypeReflection.instanceOfClass(~instance=subscription, ~class_=ctor) {
    Some(unsafeFromSubscription(subscription))
  } else {
    None
  }
