type t

type queryParam =
  | String(string)
  | Int(int)
  | Float(float)
  | Bool(bool)
  | Record(Surrealdb_RecordId.t)

let unsafeFrom: 'a => t
let string: string => t
let int: int => t
let float: float => t
let bool: bool => t
let recordId: Surrealdb_RecordId.t => t
let dateTime: Surrealdb_DateTime.t => t
let json: JSON.t => t
let array: array<t> => t
let fromParam: queryParam => t
let bindings: array<(string, queryParam)> => dict<t>
let emptyBindings: dict<t>
