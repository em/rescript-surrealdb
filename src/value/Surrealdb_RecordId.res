// src/bindings/Surrealdb_RecordId.res — SurrealDB RecordId value binding.
// Concern: bind the RecordId class from the surrealdb SDK.
// Source: surrealdb.d.ts — RecordId<Tb, Id> extends Value. Typed record reference
// with .table returning Table<Tb> and .id returning the id value. Constructor takes
// (table: string | Table, id: RecordIdValue) where RecordIdValue = string | number |
// Uuid | bigint | unknown[] | Record<string, unknown>.
type t
type ctor

@module("surrealdb") @new external make: (string, string) => t = "RecordId"
@module("surrealdb") @new external makeFromTable: (Surrealdb_Table.t, string) => t = "RecordId"
@module("surrealdb") @new external makeWithNumericId: (string, int) => t = "RecordId"
@module("surrealdb") @new external makeWithUuidId: (string, Surrealdb_Uuid.t) => t = "RecordId"
@module("surrealdb") @new external makeWithBigIntId: (string, BigInt.t) => t = "RecordId"
@module("surrealdb") @new external makeWithUnknownId: (string, unknown) => t = "RecordId"
@module("surrealdb") @new external makeFromTableWithUnknownId: (Surrealdb_Table.t, unknown) => t = "RecordId"
@module("surrealdb") external ctor: ctor = "RecordId"
external unsafeFromUnknown: unknown => t = "%identity"

@get external table: t => Surrealdb_Table.t = "table"
@get external id: t => unknown = "id"
@send external toString: t => string = "toString"
@send external equals: (t, unknown) => bool = "equals"
@send external toJSON: t => string = "toJSON"

let tableName = (rid: t): string => rid->table->Surrealdb_Table.name
let idValue = (rid: t): unknown => rid->id

let isInstance = value =>
  JsTypeReflection.instanceOfClass(~instance=value, ~class_=ctor)

let fromUnknown = value =>
  if isInstance(value) {
    Some(unsafeFromUnknown(value))
  } else {
    None
  }
