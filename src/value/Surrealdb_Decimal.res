// src/bindings/Surrealdb_Decimal.res — SurrealDB Decimal value binding.
// Concern: bind the Decimal class from the surrealdb SDK.
// Source: surrealdb.d.ts — Decimal extends Value. High-precision decimal number with
// constructors from string, number, or bigint. Has arithmetic (.add, .sub, .mul, .div),
// and precision accessors (.int, .frac, .scale).
type t
type ctor

@module("surrealdb") @new external fromString: string => t = "Decimal"
@module("surrealdb") @new external fromFloat: float => t = "Decimal"
@module("surrealdb") @new external fromBigInt: BigInt.t => t = "Decimal"
@module("surrealdb") external ctor: ctor = "Decimal"
external unsafeFromUnknown: unknown => t = "%identity"

@send external toString: t => string = "toString"
@send external equals: (t, unknown) => bool = "equals"
@send external toJSON: t => string = "toJSON"

@send external add: (t, t) => t = "add"
@send external sub: (t, t) => t = "sub"
@send external mul: (t, t) => t = "mul"
@send external div: (t, t) => t = "div"
@send external mod: (t, t) => t = "mod"
@send external abs: t => t = "abs"
@send external neg: t => t = "neg"
@send external isZero: t => bool = "isZero"
@send external isNegative: t => bool = "isNegative"
@send external compare: (t, t) => int = "compare"
@send external round: (t, int) => t = "round"
@send external toFixed: (t, int) => string = "toFixed"
@send external toFloat: t => float = "toFloat"
@send external toBigInt: t => BigInt.t = "toBigInt"
@send external toScientific: t => string = "toScientific"

@get external intPart: t => BigInt.t = "int"
@get external fracPart: t => BigInt.t = "frac"
@get external scale: t => int = "scale"

@module("surrealdb") @scope("Decimal") external fromScientificNotation: string => t = "fromScientificNotation"

let isInstance = value =>
  JsTypeReflection.instanceOfClass(~instance=value, ~class_=ctor)

let fromUnknown = value =>
  if isInstance(value) {
    Some(unsafeFromUnknown(value))
  } else {
    None
  }
