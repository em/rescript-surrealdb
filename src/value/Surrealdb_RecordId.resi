type t
type ctor

let make: (string, string) => t
let makeFromTable: (Surrealdb_Table.t, string) => t
let makeWithNumericId: (string, int) => t
let makeWithUuidId: (string, Surrealdb_Uuid.t) => t
let makeWithBigIntId: (string, BigInt.t) => t
let makeWithUnknownId: (string, unknown) => t
let makeFromTableWithUnknownId: (Surrealdb_Table.t, unknown) => t
let ctor: ctor
let table: t => Surrealdb_Table.t
let id: t => unknown
let toString: t => string
let equals: (t, unknown) => bool
let toJSON: t => string
let tableName: t => string
let idValue: t => unknown
let isInstance: unknown => bool
let fromUnknown: unknown => option<t>
