// src/bindings/Surrealdb_LiveActions.res — SurrealDB live-action constants.
// Concern: expose the installed SDK's exported LIVE_ACTIONS constant as a strict
// closed set of driver actions.
type t =
  | Create
  | Update
  | Delete
  | Killed

@module("surrealdb") external allRaw: array<string> = "LIVE_ACTIONS"

let fromString = value =>
  switch value {
  | "CREATE" => Some(Create)
  | "UPDATE" => Some(Update)
  | "DELETE" => Some(Delete)
  | "KILLED" => Some(Killed)
  | _ => None
  }

let toString = value =>
  switch value {
  | Create => "CREATE"
  | Update => "UPDATE"
  | Delete => "DELETE"
  | Killed => "KILLED"
  }

let values = () =>
  allRaw->Belt.Array.keepMap(fromString)
