// src/bindings/Surrealdb_RecordIdRange.res — SurrealDB RecordIdRange value binding.
// Concern: bind the RecordIdRange class from the surrealdb SDK.
// Source: surrealdb.d.ts — RecordIdRange<Tb, Id> extends Value. Represents a range of
// record IDs for graph traversal with .table, .begin, and .end accessors. Bounds can
// be BoundIncluded, BoundExcluded, or undefined (unbounded).
type t
type ctor

@module("surrealdb") @new external makeRaw: (string, option<unknown>, option<unknown>) => t = "RecordIdRange"
@module("surrealdb") external ctor: ctor = "RecordIdRange"
external unsafeFromUnknown: unknown => t = "%identity"
external boundToUnknown: Surrealdb_RangeBound.t => unknown = "%identity"

@get external table: t => Surrealdb_Table.t = "table"
@get external beginRaw: t => option<unknown> = "begin"
@get external endRaw: t => option<unknown> = "end"
@send external toString: t => string = "toString"
@send external equals: (t, unknown) => bool = "equals"
@send external toJSON: t => string = "toJSON"

let make = (~table, ~begin=?, ~end=?, ()) =>
  makeRaw(
    table,
    begin->Option.map(boundToUnknown),
    end->Option.map(boundToUnknown),
  )

let begin = value =>
  switch beginRaw(value) {
  | Some(bound) => Surrealdb_RangeBound.fromUnknown(bound)
  | None => None
  }

let end_ = value =>
  switch endRaw(value) {
  | Some(bound) => Surrealdb_RangeBound.fromUnknown(bound)
  | None => None
  }

let isInstance = value =>
  JsTypeReflection.instanceOfClass(~instance=value, ~class_=ctor)

let fromUnknown = value =>
  if isInstance(value) {
    Some(unsafeFromUnknown(value))
  } else {
    None
  }
