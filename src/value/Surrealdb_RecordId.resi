type t
type ctor
type rec component =
  | Undefined
  | Null
  | Bool(bool)
  | Int(int)
  | Float(float)
  | String(string)
  | BigInt(BigInt.t)
  | ValueClass(Surrealdb_ValueClass.t)
  | Array(array<component>)
  | Object(dict<component>)

type idValue =
  | StringId(string)
  | NumberId(float)
  | UuidId(Surrealdb_Uuid.t)
  | BigIntId(BigInt.t)
  | ArrayId(array<component>)
  | ObjectId(dict<component>)

let make: (string, string) => t
let makeFromTable: (Surrealdb_Table.t, string) => t
let makeWithNumericId: (string, int) => t
let makeWithNumberId: (string, float) => t
let makeWithUuidId: (string, Surrealdb_Uuid.t) => t
let makeWithBigIntId: (string, BigInt.t) => t
let makeWithIdValue: (string, idValue) => t
let makeFromTableWithIdValue: (Surrealdb_Table.t, idValue) => t
let ctor: ctor
let table: t => Surrealdb_Table.t
let toString: t => string
let equals: (t, unknown) => bool
let toJSON: t => string
let tableName: t => string
let idValue: t => option<idValue>
let isInstance: unknown => bool
let fromUnknown: unknown => option<t>
