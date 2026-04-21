type t =
  | Create
  | Update
  | Delete
  | Killed

let allRaw: array<string>
let fromString: string => option<t>
let toString: t => string
let values: unit => array<t>
