type t =
  | Disconnected
  | Connecting
  | Reconnecting
  | Connected

let parse: string => option<t>
let toString: t => string
