type t
type kind =
  | Include
  | Exclude

let included: unknown => t
let excluded: unknown => t
let kind: t => kind
let isIncluded: t => bool
let isExcluded: t => bool
let value: t => Surrealdb_BoundValue.t
let isInstance: unknown => bool
let fromUnknown: unknown => option<t>
