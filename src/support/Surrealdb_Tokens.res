// src/bindings/Surrealdb_Tokens.res — SurrealDB token-object binding.
// Concern: bind the Tokens object returned by signin(), signup(), and
// authenticate() without collapsing it to untyped JSON.
type t

@obj
external make: (
  ~access: string,
  ~refresh: string=?,
  unit,
) => t = ""

@get external access: t => string = "access"
@get external refreshRaw: t => Nullable.t<string> = "refresh"

let refresh = tokens =>
  tokens->refreshRaw->Nullable.toOption

let toJSON = tokens =>
  [
    [("access", JSON.Encode.string(tokens->access))],
    switch tokens->refresh {
    | Some(value) => [("refresh", JSON.Encode.string(value))]
    | None => []
    },
  ]
  ->Belt.Array.concatMany
  ->Dict.fromArray
  ->JSON.Encode.object
