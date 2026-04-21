// src/bindings/Surrealdb_DateTime.res — SurrealDB DateTime value binding.
// Concern: bind the DateTime class from the surrealdb SDK.
// Source: surrealdb.d.ts — DateTime extends Value. Nanosecond-precision datetime with
// constructors from Date, ISO string, number, bigint, or tuple. Has .toISOString(),
// .toDate(), .milliseconds, .seconds, .nanoseconds, arithmetic with Duration, and
// .compare() for ordering.
type t
type ctor
type compact = (BigInt.t, BigInt.t)

@module("surrealdb") @new external now: unit => t = "DateTime"
@module("surrealdb") @new external fromDate: Date.t => t = "DateTime"
@module("surrealdb") @new external fromString: string => t = "DateTime"
@module("surrealdb") @new external fromMilliseconds: float => t = "DateTime"
@module("surrealdb") @new external fromBigInt: BigInt.t => t = "DateTime"
@module("surrealdb") @new external fromCompact: compact => t = "DateTime"
@module("surrealdb") external ctor: ctor = "DateTime"
external unsafeFromUnknown: unknown => t = "%identity"

@send external toISOString: t => string = "toISOString"
@send external toDate: t => Date.t = "toDate"
@send external toString: t => string = "toString"
@send external equals: (t, unknown) => bool = "equals"
@send external toJSON: t => string = "toJSON"
@send external toCompact: t => compact = "toCompact"

@get external nanoseconds: t => BigInt.t = "nanoseconds"
@get external microseconds: t => BigInt.t = "microseconds"
@get external milliseconds: t => float = "milliseconds"
@get external seconds: t => float = "seconds"

@send external add: (t, Surrealdb_Duration.t) => t = "add"
@send external sub: (t, Surrealdb_Duration.t) => t = "sub"
@send external diff: (t, t) => Surrealdb_Duration.t = "diff"
@send external compare: (t, t) => int = "compare"

@module("surrealdb") @scope("DateTime") external parseString: string => compact = "parseString"
@module("surrealdb") @scope("DateTime") external epoch: unit => t = "epoch"
@module("surrealdb") @scope("DateTime") external fromEpochNanoseconds: BigInt.t => t = "fromEpochNanoseconds"
@module("surrealdb") @scope("DateTime") external fromEpochMicroseconds: BigInt.t => t = "fromEpochMicroseconds"
@module("surrealdb") @scope("DateTime") external fromEpochMilliseconds: float => t = "fromEpochMilliseconds"
@module("surrealdb") @scope("DateTime") external fromEpochSeconds: float => t = "fromEpochSeconds"
@module("surrealdb") @scope("DateTime") external nowValue: unit => t = "now"

let isInstance = value =>
  JsTypeReflection.instanceOfClass(~instance=value, ~class_=ctor)

let fromUnknown = value =>
  if isInstance(value) {
    Some(unsafeFromUnknown(value))
  } else {
    None
  }
