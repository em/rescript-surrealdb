// src/bindings/Surrealdb_RangeBound.res — SurrealDB range-bound binding.
// Concern: bind the BoundIncluded and BoundExcluded classes used by Range values.
// Source: node_modules/surrealdb/dist/surrealdb.d.ts — Range bounds are represented by
// BoundIncluded<T>, BoundExcluded<T>, or undefined.
// Boundary: construction stays on the public BoundValue algebra so typed callers
// can build range bounds without falling back to raw `unknown`.
type t
type rec input =
  | Undefined
  | Null
  | Bool(bool)
  | Int(int)
  | Float(float)
  | String(string)
  | BigInt(BigInt.t)
  | ValueClass(Surrealdb_ValueClass.t)
  | Array(array<input>)
  | Object(dict<input>)
type rawIncluded
type rawExcluded
type includedCtor
type excludedCtor
type kind =
  | Include
  | Exclude

external toUnknown: 'a => unknown = "%identity"
external unsafeFromUnknown: unknown => t = "%identity"
external unsafeAsIncluded: t => rawIncluded = "%identity"
external unsafeAsExcluded: t => rawExcluded = "%identity"

@module("surrealdb") @new external includeValueRaw: unknown => rawIncluded = "BoundIncluded"
@module("surrealdb") @new external excludeValueRaw: unknown => rawExcluded = "BoundExcluded"
@module("surrealdb") external includedCtor: includedCtor = "BoundIncluded"
@module("surrealdb") external excludedCtor: excludedCtor = "BoundExcluded"
@get external includedValueOf: rawIncluded => unknown = "value"
@get external excludedValueOf: rawExcluded => unknown = "value"

let rec rawValue = (value: input) =>
  switch value {
  | Undefined => Nullable.undefined->toUnknown
  | Null => Nullable.null->toUnknown
  | Bool(raw) => raw->toUnknown
  | Int(raw) => raw->toUnknown
  | Float(raw) => raw->toUnknown
  | String(raw) => raw->toUnknown
  | BigInt(raw) => raw->toUnknown
  | ValueClass(raw) => raw->Surrealdb_ValueClass.toUnknown
  | Array(raw) => raw->Array.map(rawValue)->toUnknown
  | Object(raw) =>
    let result = Dict.make()
    raw->Dict.toArray->Array.forEach(((key, item)) => result->Dict.set(key, item->rawValue))
    result->toUnknown
  }

let included = value =>
  value->rawValue->includeValueRaw->toUnknown->unsafeFromUnknown

let excluded = value =>
  value->rawValue->excludeValueRaw->toUnknown->unsafeFromUnknown

let kind = bound =>
  if JsTypeReflection.instanceOfClass(~instance=bound, ~class_=includedCtor) {
    Include
  } else {
    Exclude
  }

let isIncluded = bound =>
  bound->kind == Include

let isExcluded = bound =>
  bound->kind == Exclude

let value = bound =>
  if bound->isIncluded {
    bound->unsafeAsIncluded->includedValueOf->Surrealdb_BoundValue.fromUnknown
  } else {
    bound->unsafeAsExcluded->excludedValueOf->Surrealdb_BoundValue.fromUnknown
  }

let isIncludedInstance = value =>
  JsTypeReflection.instanceOfClass(~instance=value, ~class_=includedCtor)

let isExcludedInstance = value =>
  JsTypeReflection.instanceOfClass(~instance=value, ~class_=excludedCtor)

let isInstance = value =>
  isIncludedInstance(value) || isExcludedInstance(value)

let fromUnknown = value =>
  if isIncludedInstance(value) {
    Some(unsafeFromUnknown(value))
  } else if isExcludedInstance(value) {
    Some(unsafeFromUnknown(value))
  } else {
    None
  }
