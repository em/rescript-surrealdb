type t

type queryParam =
  | String(string)
  | Int(int)
  | Float(float)
  | Bool(bool)
  | Record(Surrealdb_RecordId.t)

let string: string => t
let int: int => t
let float: float => t
let bool: bool => t
let bigInt: BigInt.t => t
let table: Surrealdb_Table.t => t
let recordId: Surrealdb_RecordId.t => t
let dateTime: Surrealdb_DateTime.t => t
let uuid: Surrealdb_Uuid.t => t
let decimal: Surrealdb_Decimal.t => t
let duration: Surrealdb_Duration.t => t
let fileRef: Surrealdb_FileRef.t => t
let stringRecordId: Surrealdb_StringRecordId.t => t
let future: Surrealdb_Future.t => t
let range: Surrealdb_Range.t => t
let rangeBound: Surrealdb_RangeBound.t => t
let recordIdRange: Surrealdb_RecordIdRange.t => t
let geometry: Surrealdb_Geometry.t => t
let valueClass: Surrealdb_ValueClass.t => t
let json: JSON.t => t
let array: array<t> => t
let object: dict<t> => t
let fromParam: queryParam => t
let bindings: array<(string, queryParam)> => dict<t>
let emptyBindings: dict<t>
