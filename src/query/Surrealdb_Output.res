// src/bindings/Surrealdb_Output.res — SurrealDB mutation/select output modes.
// Concern: model the public SDK output enum used by create/update/delete/relate
// and related query builders.
type t =
  | None
  | Null
  | Diff
  | Before
  | After

let toString = value =>
  switch value {
  | None => "none"
  | Null => "null"
  | Diff => "diff"
  | Before => "before"
  | After => "after"
  }

let parse = raw =>
  switch raw->String.trim->String.toLowerCase {
  | "none" => Some(None)
  | "null" => Some(Null)
  | "diff" => Some(Diff)
  | "before" => Some(Before)
  | "after" => Some(After)
  | _ => None
  }
