// src/bindings/Surrealdb_RangeBound.res — SurrealDB range-bound binding.
// Concern: bind the BoundIncluded and BoundExcluded classes used by Range values.
// Source: node_modules/surrealdb/dist/surrealdb.d.ts — Range bounds are represented by
// BoundIncluded<T>, BoundExcluded<T>, or undefined.
type included<'a>
type excluded<'a>
type includedCtor
type excludedCtor

type t<'a> =
  | Included(included<'a>)
  | Excluded(excluded<'a>)

@module("surrealdb") @new external includeValue: 'a => included<'a> = "BoundIncluded"
@module("surrealdb") @new external excludeValue: 'a => excluded<'a> = "BoundExcluded"
@module("surrealdb") external includedCtor: includedCtor = "BoundIncluded"
@module("surrealdb") external excludedCtor: excludedCtor = "BoundExcluded"
external unsafeIncludedFromUnknown: unknown => included<'a> = "%identity"
external unsafeExcludedFromUnknown: unknown => excluded<'a> = "%identity"
external unsafeToUnknown: 'a => unknown = "%identity"

@get external includedValueOf: included<'a> => 'a = "value"
@get external excludedValueOf: excluded<'a> => 'a = "value"

let included = value => Included(includeValue(value))
let excluded = value => Excluded(excludeValue(value))

let value = bound =>
  switch bound {
  | Included(item) => item->includedValueOf
  | Excluded(item) => item->excludedValueOf
  }

let toUnknown = bound =>
  switch bound {
  | Included(item) => unsafeToUnknown(item)
  | Excluded(item) => unsafeToUnknown(item)
  }

let isIncludedInstance = value =>
  JsTypeReflection.instanceOfClass(~instance=value, ~class_=includedCtor)

let isExcludedInstance = value =>
  JsTypeReflection.instanceOfClass(~instance=value, ~class_=excludedCtor)

let fromUnknown = value =>
  if isIncludedInstance(value) {
    Some(Included(unsafeIncludedFromUnknown(value)))
  } else if isExcludedInstance(value) {
    Some(Excluded(unsafeExcludedFromUnknown(value)))
  } else {
    None
  }
