// src/bindings/Surrealdb_RecordId.res — SurrealDB RecordId value binding.
// Concern: bind the RecordId class from the surrealdb SDK.
// Source: surrealdb.d.ts — RecordId<Tb, Id> extends Value. Typed record reference
// with .table returning Table<Tb> and .id returning the id value. Constructor takes
// (table: string | Table, id: RecordIdValue) where RecordIdValue = string | number |
// Uuid | bigint | unknown[] | Record<string, unknown>.
type t
type ctor
type idValue =
  | StringId(string)
  | NumberId(float)
  | UuidId(Surrealdb_Uuid.t)
  | BigIntId(BigInt.t)
  | ArrayId(array<JSON.t>)
  | ObjectId(dict<JSON.t>)

@module("surrealdb") @new external make: (string, string) => t = "RecordId"
@module("surrealdb") @new external makeFromTable: (Surrealdb_Table.t, string) => t = "RecordId"
@module("surrealdb") @new external makeWithNumericId: (string, int) => t = "RecordId"
@module("surrealdb") @new external makeWithNumberId: (string, float) => t = "RecordId"
@module("surrealdb") @new external makeWithUuidId: (string, Surrealdb_Uuid.t) => t = "RecordId"
@module("surrealdb") @new external makeWithBigIntId: (string, BigInt.t) => t = "RecordId"
@module("surrealdb") @new external makeWithRawId: (string, unknown) => t = "RecordId"
@module("surrealdb") @new external makeFromTableWithRawId: (Surrealdb_Table.t, unknown) => t = "RecordId"
@module("surrealdb") external ctor: ctor = "RecordId"
@module("surrealdb") external jsonifyRaw: unknown => unknown = "jsonify"
external unsafeFromUnknown: unknown => t = "%identity"
external asString: unknown => string = "%identity"
external asFloat: unknown => float = "%identity"
external asBigInt: unknown => BigInt.t = "%identity"
external rawStringToUnknown: string => unknown = "%identity"
external rawFloatToUnknown: float => unknown = "%identity"
external rawUuidToUnknown: Surrealdb_Uuid.t => unknown = "%identity"
external rawBigIntToUnknown: BigInt.t => unknown = "%identity"
external rawArrayToUnknown: array<JSON.t> => unknown = "%identity"
external rawDictToUnknown: dict<JSON.t> => unknown = "%identity"
external asJsonArray: unknown => array<JSON.t> = "%identity"
external asJsonDict: unknown => dict<JSON.t> = "%identity"

@get external table: t => Surrealdb_Table.t = "table"
@get external idRaw: t => unknown = "id"
@send external toString: t => string = "toString"
@send external equals: (t, unknown) => bool = "equals"
@send external toJSON: t => string = "toJSON"

let tableName = (rid: t): string => rid->table->Surrealdb_Table.name

let rawIdValue = value =>
  switch value {
  | StringId(raw) => raw->rawStringToUnknown
  | NumberId(raw) => raw->rawFloatToUnknown
  | UuidId(raw) => raw->rawUuidToUnknown
  | BigIntId(raw) => raw->rawBigIntToUnknown
  | ArrayId(raw) => raw->rawArrayToUnknown
  | ObjectId(raw) => raw->rawDictToUnknown
  }

let makeWithIdValue = (table, value) =>
  makeWithRawId(table, value->rawIdValue)

let makeFromTableWithIdValue = (table, value) =>
  makeFromTableWithRawId(table, value->rawIdValue)

let idValue = rid =>
  switch Surrealdb_Uuid.fromUnknown(rid->idRaw) {
  | Some(value) => UuidId(value)
  | None =>
    switch typeof(rid->idRaw) {
    | #string => StringId(rid->idRaw->asString)
    | #number => NumberId(rid->idRaw->asFloat)
    | #bigint => BigIntId(rid->idRaw->asBigInt)
    | #object =>
      if Array.isArray(rid->idRaw) {
        ArrayId(rid->idRaw->jsonifyRaw->asJsonArray)
      } else {
        ObjectId(rid->idRaw->jsonifyRaw->asJsonDict)
      }
    | #undefined | #boolean | #function | #symbol =>
      throw(Failure(`Unsupported RecordId runtime id: ${rid->toString}`))
    }
  }

let isInstance = value =>
  JsTypeReflection.instanceOfClass(~instance=value, ~class_=ctor)

let fromUnknown = value =>
  if isInstance(value) {
    Some(unsafeFromUnknown(value))
  } else {
    None
  }
