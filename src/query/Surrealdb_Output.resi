type t =
  | None
  | Null
  | Diff
  | Before
  | After

let toString: t => string
let parse: string => option<t>
