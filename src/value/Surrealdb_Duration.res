// src/bindings/Surrealdb_Duration.res — SurrealDB Duration value binding.
// Concern: bind the Duration class from the surrealdb SDK.
// Source: surrealdb.d.ts — Duration extends Value. Nanosecond-precision duration with
// constructors from string ("1h30m"), tuple, or clone. Has arithmetic (.add, .sub),
// and formatting (.toString).
type t
type ctor
type compact = array<BigInt.t>

@module("surrealdb") @new external fromString: string => t = "Duration"
@module("surrealdb") @new external fromBigInt: BigInt.t => t = "Duration"
@module("surrealdb") @new external fromCompact: compact => t = "Duration"
@module("surrealdb") external ctor: ctor = "Duration"
external unsafeFromUnknown: unknown => t = "%identity"

@send external toString: t => string = "toString"
@send external equals: (t, unknown) => bool = "equals"
@send external toJSON: t => string = "toJSON"
@send external toCompact: t => compact = "toCompact"

@send external add: (t, t) => t = "add"
@send external sub: (t, t) => t = "sub"
@send external mulByInt: (t, int) => t = "mul"
@send external mulByBigInt: (t, BigInt.t) => t = "mul"
@send external divByDuration: (t, t) => BigInt.t = "div"
@send external divByInt: (t, int) => t = "div"
@send external divByBigInt: (t, BigInt.t) => t = "div"
@send external mod: (t, t) => t = "mod"

@get external nanoseconds: t => BigInt.t = "nanoseconds"
@get external microseconds: t => BigInt.t = "microseconds"
@get external milliseconds: t => BigInt.t = "milliseconds"
@get external seconds: t => BigInt.t = "seconds"
@get external minutes: t => BigInt.t = "minutes"
@get external hours: t => BigInt.t = "hours"
@get external days: t => BigInt.t = "days"
@get external weeks: t => BigInt.t = "weeks"
@get external years: t => BigInt.t = "years"

@module("surrealdb") @scope("Duration") external parseString: string => compact = "parseString"
@module("surrealdb") @scope("Duration") external parseFloat: string => t = "parseFloat"
@module("surrealdb") @scope("Duration") external nanosecondsValue: int => t = "nanoseconds"
@module("surrealdb") @scope("Duration") external microsecondsValue: int => t = "microseconds"
@module("surrealdb") @scope("Duration") external millisecondsValue: int => t = "milliseconds"
@module("surrealdb") @scope("Duration") external secondsValue: int => t = "seconds"
@module("surrealdb") @scope("Duration") external minutesValue: int => t = "minutes"
@module("surrealdb") @scope("Duration") external hoursValue: int => t = "hours"
@module("surrealdb") @scope("Duration") external daysValue: int => t = "days"
@module("surrealdb") @scope("Duration") external weeksValue: int => t = "weeks"
@module("surrealdb") @scope("Duration") external yearsValue: int => t = "years"
@module("surrealdb") @scope("Duration") external measure: unit => unit => t = "measure"

let isInstance = value =>
  JsTypeReflection.instanceOfClass(~instance=value, ~class_=ctor)

let fromUnknown = value =>
  if isInstance(value) {
    Some(unsafeFromUnknown(value))
  } else {
    None
  }
