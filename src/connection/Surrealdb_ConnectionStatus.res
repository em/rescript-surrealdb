// src/bindings/Surrealdb_ConnectionStatus.res — SurrealDB connection status union.
// Concern: model the closed ConnectionStatus string union from surrealdb.d.ts.
type t =
  | Disconnected
  | Connecting
  | Reconnecting
  | Connected

let parse = raw =>
  switch raw->String.trim->String.toLowerCase {
  | "disconnected" => Some(Disconnected)
  | "connecting" => Some(Connecting)
  | "reconnecting" => Some(Reconnecting)
  | "connected" => Some(Connected)
  | _ => None
  }

let toString = value =>
  switch value {
  | Disconnected => "disconnected"
  | Connecting => "connecting"
  | Reconnecting => "reconnecting"
  | Connected => "connected"
  }
