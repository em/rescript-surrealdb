// src/bindings/Surrealdb_QueryType.res — SurrealDB query type union.
// Concern: model the closed QueryType string union from surrealdb.d.ts.
type t =
  | Live
  | Kill
  | Other

let parse = raw =>
  switch raw->String.trim->String.toLowerCase {
  | "live" => Some(Live)
  | "kill" => Some(Kill)
  | "other" => Some(Other)
  | _ => None
  }

let toString = value =>
  switch value {
  | Live => "live"
  | Kill => "kill"
  | Other => "other"
  }
