// src/bindings/Surrealdb_RecordId.res — SurrealDB RecordId value binding.
// Concern: bind the RecordId class without flattening compound ids through JSON.
// Source: surrealdb.d.ts — RecordId<Tb, Id> extends Value. Constructor takes
// `RecordIdValue = string | number | Uuid | bigint | unknown[] | Record<string, unknown>`.
// Boundary: top-level id cases are closed, while compound array/object leaves use
// a recursive supported subset that preserves nullish values, BigInt, and SDK
// value classes without widening the whole surface to `unknown`.
// Why this shape: nested function and symbol leaves are not preserved by a sound
// public algebraic type here, so `idValue` returns `option<idValue>` and keeps
// the unsupported remainder explicit.
// Coverage: tests/value/SurrealdbValueSurface_test.res and
// tests/query/SurrealdbPublicSurface_test.res exercise compound-id round-trips.
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

@module("surrealdb") @new external make: (string, string) => t = "RecordId"
@module("surrealdb") @new external makeFromTable: (Surrealdb_Table.t, string) => t = "RecordId"
@module("surrealdb") @new external makeWithNumericId: (string, int) => t = "RecordId"
@module("surrealdb") @new external makeWithNumberId: (string, float) => t = "RecordId"
@module("surrealdb") @new external makeWithUuidId: (string, Surrealdb_Uuid.t) => t = "RecordId"
@module("surrealdb") @new external makeWithBigIntId: (string, BigInt.t) => t = "RecordId"
@module("surrealdb") @new external makeWithRawId: (string, unknown) => t = "RecordId"
@module("surrealdb") @new external makeFromTableWithRawId: (Surrealdb_Table.t, unknown) => t = "RecordId"
@module("surrealdb") external ctor: ctor = "RecordId"
external unsafeFromUnknown: unknown => t = "%identity"
external asNullable: unknown => Nullable.t<unknown> = "%identity"
external asString: unknown => string = "%identity"
external asBool: unknown => bool = "%identity"
external asFloat: unknown => float = "%identity"
external asInt: unknown => int = "%identity"
external asBigInt: unknown => BigInt.t = "%identity"
external rawBoolToUnknown: bool => unknown = "%identity"
external rawStringToUnknown: string => unknown = "%identity"
external rawFloatToUnknown: float => unknown = "%identity"
external rawUuidToUnknown: Surrealdb_Uuid.t => unknown = "%identity"
external rawBigIntToUnknown: BigInt.t => unknown = "%identity"
external rawArrayToUnknown: array<unknown> => unknown = "%identity"
external rawDictToUnknown: dict<unknown> => unknown = "%identity"
external asUnknownArray: unknown => array<unknown> = "%identity"
external asUnknownDict: unknown => dict<unknown> = "%identity"
external nullableToUnknown: Nullable.t<'a> => unknown = "%identity"
external rawIntToUnknown: int => unknown = "%identity"

@get external table: t => Surrealdb_Table.t = "table"
@get external idRaw: t => unknown = "id"
@send external toString: t => string = "toString"
@send external equals: (t, unknown) => bool = "equals"
@send external toJSON: t => string = "toJSON"

let tableName = (rid: t): string => rid->table->Surrealdb_Table.name

let rec rawComponent = value =>
  switch value {
  | Undefined => Nullable.undefined->nullableToUnknown
  | Null => Nullable.null->nullableToUnknown
  | Bool(raw) => raw->rawBoolToUnknown
  | Int(raw) => raw->rawIntToUnknown
  | Float(raw) => raw->rawFloatToUnknown
  | String(raw) => raw->rawStringToUnknown
  | BigInt(raw) => raw->rawBigIntToUnknown
  | ValueClass(raw) => raw->Surrealdb_ValueClass.toUnknown
  | Array(raw) =>
    raw->Array.map(rawComponent)->rawArrayToUnknown
  | Object(raw) =>
    raw
    ->Dict.toArray
    ->Array.map(((key, item)) => (key, item->rawComponent))
    ->Dict.fromArray
    ->rawDictToUnknown
  }

let rawIdValue = value =>
  switch value {
  | StringId(raw) => raw->rawStringToUnknown
  | NumberId(raw) => raw->rawFloatToUnknown
  | UuidId(raw) => raw->rawUuidToUnknown
  | BigIntId(raw) => raw->rawBigIntToUnknown
  | ArrayId(raw) => raw->Array.map(rawComponent)->rawArrayToUnknown
  | ObjectId(raw) =>
    raw
    ->Dict.toArray
    ->Array.map(((key, item)) => (key, item->rawComponent))
    ->Dict.fromArray
    ->rawDictToUnknown
  }

let makeWithIdValue = (table, value) =>
  makeWithRawId(table, value->rawIdValue)

let makeFromTableWithIdValue = (table, value) =>
  makeFromTableWithRawId(table, value->rawIdValue)

let rec arrayComponentsFromUnknown = values =>
  values->Array.reduce(Some(([]: array<component>)), (state, raw) =>
    switch (state, componentFromUnknown(raw)) {
    | (Some(items), Some(value)) => Some(Array.concat(items, [value]))
    | _ => None
    }
  )

and dictComponentsFromUnknown = values =>
  values->Dict.toArray->Array.reduce(Some(([]: array<(string, component)>)), (state, (key, raw)) =>
    switch (state, componentFromUnknown(raw)) {
    | (Some(items), Some(value)) => Some(Array.concat(items, [(key, value)]))
    | _ => None
    }
  )->Option.map(Dict.fromArray)

and componentFromUnknown = raw =>
  switch Surrealdb_ValueClass.fromUnknown(raw) {
  | Some(value) => Some(ValueClass(value))
  | None =>
    switch typeof(raw) {
    | #undefined => Some(Undefined)
    | #string => Some(String(asString(raw)))
    | #boolean => Some(Bool(asBool(raw)))
    | #number =>
      let value = asFloat(raw)
      if Math.floor(value) == value && value >= -2147483648.0 && value <= 2147483647.0 {
        Some(Int(asInt(raw)))
      } else {
        Some(Float(value))
      }
    | #bigint => Some(BigInt(asBigInt(raw)))
    | #function | #symbol => None
    | #object =>
      if Nullable.isNullable(asNullable(raw)) {
        Some(Null)
      } else if Array.isArray(raw) {
        raw->asUnknownArray->arrayComponentsFromUnknown->Option.map(value => Array(value))
      } else {
        raw->asUnknownDict->dictComponentsFromUnknown->Option.map(value => Object(value))
      }
    }
  }

let idValue = rid =>
  switch Surrealdb_Uuid.fromUnknown(rid->idRaw) {
  | Some(value) => Some(UuidId(value))
  | None =>
    switch typeof(rid->idRaw) {
    | #string => Some(StringId(rid->idRaw->asString))
    | #number => Some(NumberId(rid->idRaw->asFloat))
    | #bigint => Some(BigIntId(rid->idRaw->asBigInt))
    | #object =>
      if Nullable.isNullable(asNullable(rid->idRaw)) {
        None
      } else if Array.isArray(rid->idRaw) {
        rid->idRaw->asUnknownArray->arrayComponentsFromUnknown->Option.map(value => ArrayId(value))
      } else {
        switch Surrealdb_ValueClass.fromUnknown(rid->idRaw) {
        | Some(_) => None
        | None => rid->idRaw->asUnknownDict->dictComponentsFromUnknown->Option.map(value => ObjectId(value))
        }
      }
    | #undefined | #boolean | #function | #symbol => None
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
