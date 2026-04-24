type t =
  | Live
  | Kill
  | Other

let parse: string => option<t>
let toString: t => string
