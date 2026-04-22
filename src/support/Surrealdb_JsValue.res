// src/bindings/Surrealdb_JsValue.res — SurrealDB JS value boundary.
// Concern: construct SDK-compatible JavaScript values and query bindings.
// Source: node_modules/surrealdb/dist/surrealdb.d.ts — BoundQuery bindings and
// queryable verbs accept plain JS values, typed SDK values such as RecordId and
// DateTime, and JSON-shaped values.
type t

type queryParam =
  | String(string)
  | Int(int)
  | Float(float)
  | Bool(bool)
  | Record(Surrealdb_RecordId.t)

external unsafeFrom: 'a => t = "%identity"

let string = (value: string): t => unsafeFrom(value)
let int = (value: int): t => unsafeFrom(value)
let float = (value: float): t => unsafeFrom(value)
let bool = (value: bool): t => unsafeFrom(value)
let bigInt = (value: BigInt.t): t => unsafeFrom(value)
let table = (value: Surrealdb_Table.t): t => unsafeFrom(value)
let recordId = (value: Surrealdb_RecordId.t): t => unsafeFrom(value)
let dateTime = (value: Surrealdb_DateTime.t): t => unsafeFrom(value)
let uuid = (value: Surrealdb_Uuid.t): t => unsafeFrom(value)
let decimal = (value: Surrealdb_Decimal.t): t => unsafeFrom(value)
let duration = (value: Surrealdb_Duration.t): t => unsafeFrom(value)
let fileRef = (value: Surrealdb_FileRef.t): t => unsafeFrom(value)
let stringRecordId = (value: Surrealdb_StringRecordId.t): t => unsafeFrom(value)
let future = (value: Surrealdb_Future.t): t => unsafeFrom(value)
let range = (value: Surrealdb_Range.t): t => unsafeFrom(value)
let rangeBound = (value: Surrealdb_RangeBound.t): t => unsafeFrom(value)
let recordIdRange = (value: Surrealdb_RecordIdRange.t): t => unsafeFrom(value)
let geometry = (value: Surrealdb_Geometry.t): t => unsafeFrom(value)
let valueClass = (value: Surrealdb_ValueClass.t): t => unsafeFrom(value)
let json = (value: JSON.t): t => unsafeFrom(value)
let array = (value: array<t>): t => unsafeFrom(value)
let object = (value: dict<t>): t => unsafeFrom(value)

let fromParam = param =>
  switch param {
  | String(value) => string(value)
  | Int(value) => int(value)
  | Float(value) => float(value)
  | Bool(value) => bool(value)
  | Record(value) => recordId(value)
  }

let bindings = pairs =>
  pairs
  ->Array.map(((name, value)) => (name, value->fromParam))
  ->Dict.fromArray

let emptyBindings: dict<t> = Dict.fromArray([])
