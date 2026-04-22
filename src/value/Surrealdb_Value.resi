type unsupported =
  | BigIntValue(BigInt.t)
  | FunctionValue
  | SymbolValue

type rec t =
  | None
  | Null
  | Bool(bool)
  | Int(int)
  | Float(float)
  | String(string)
  | Unsupported(unsupported)
  | FileRef(Surrealdb_FileRef.t)
  | Future(Surrealdb_Future.t)
  | Decimal(Surrealdb_Decimal.t)
  | Datetime(Surrealdb_DateTime.t)
  | Duration(Surrealdb_Duration.t)
  | Uuid(Surrealdb_Uuid.t)
  | Table(Surrealdb_Table.t)
  | RecordId(Surrealdb_RecordId.t)
  | RecordIdRange(Surrealdb_RecordIdRange.t)
  | StringRecordId(Surrealdb_StringRecordId.t)
  | Range(Surrealdb_Range.t)
  | Geometry(Surrealdb_Geometry.t)
  | Array(array<t>)
  | Object(dict<t>)

let classifyTypedValue: unknown => option<t>
let fromUnknown: unknown => t
let toText: t => string
let toJSON: t => JSON.t
