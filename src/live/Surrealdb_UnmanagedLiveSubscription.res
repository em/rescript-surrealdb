// src/bindings/Surrealdb_UnmanagedLiveSubscription.res — unmanaged live subscription binding.
// Concern: classify the exported UnmanagedLiveSubscription subclass without
// narrowing the common live-subscription surface.
type t
type ctor

external asLiveSubscription: t => Surrealdb_LiveSubscription.t = "%identity"
external unsafeFromSubscription: Surrealdb_LiveSubscription.t => t = "%identity"

@module("surrealdb") external ctor: ctor = "UnmanagedLiveSubscription"

let fromSubscription = subscription =>
  if JsTypeReflection.instanceOfClass(~instance=subscription, ~class_=ctor) {
    Some(unsafeFromSubscription(subscription))
  } else {
    None
  }
