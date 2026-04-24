// src/bindings/Surrealdb_Frame.res — SurrealDB stream frame binding.
// Concern: bind the Frame / ValueFrame / ErrorFrame / DoneFrame hierarchy used by
// query and API stream() methods.
type t<'value>
type ctor
type value<'value>
type error<'value>
type done<'value>

external toUnknown: 'a => unknown = "%identity"
external unsafeFromUnknown: unknown => t<'value> = "%identity"
external unsafeValueFromUnknown: unknown => value<'value> = "%identity"
external unsafeErrorFromUnknown: unknown => error<'value> = "%identity"
external unsafeDoneFromUnknown: unknown => done<'value> = "%identity"

@module("surrealdb") external ctor: ctor = "Frame"
@module("surrealdb") external valueCtor: ctor = "ValueFrame"
@module("surrealdb") external errorCtor: ctor = "ErrorFrame"
@module("surrealdb") external doneCtor: ctor = "DoneFrame"

@get external query: t<'value> => int = "query"
@send external isOf: (t<'value>, int) => bool = "isOf"
@send external isValue_: t<'value> => bool = "isValue"
@send external isError_: t<'value> => bool = "isError"
@send external isDone_: t<'value> => bool = "isDone"
@send external isValueOf: (t<'value>, int) => bool = "isValueOf"
@send external isErrorOf: (t<'value>, int) => bool = "isErrorOf"
@send external isDoneOf: (t<'value>, int) => bool = "isDoneOf"

@get external valueData: value<'value> => 'value = "value"
@get external valueIsSingle: value<'value> => bool = "isSingle"

@get external errorStatsRaw: error<'value> => Nullable.t<Surrealdb_QueryStats.t> = "stats"
@get external errorValue: error<'value> => Surrealdb_ServerError.t = "error"
@send external throw_: error<'value> => 'a = "throw"

@get external doneStatsRaw: done<'value> => Nullable.t<Surrealdb_QueryStats.t> = "stats"
@get external doneTypeRaw: done<'value> => string = "type"

let fromUnknownWith = (~value, ~ctor, cast) =>
  if JsTypeReflection.instanceOfClass(~instance=value, ~class_=ctor) {
    Some(cast(value))
  } else {
    None
  }

let fromUnknown = value =>
  fromUnknownWith(~value, ~ctor, unsafeFromUnknown)

let asValue = frame =>
  fromUnknownWith(~value=toUnknown(frame), ~ctor=valueCtor, unsafeValueFromUnknown)

let asError = frame =>
  fromUnknownWith(~value=toUnknown(frame), ~ctor=errorCtor, unsafeErrorFromUnknown)

let asDone = frame =>
  fromUnknownWith(~value=toUnknown(frame), ~ctor=doneCtor, unsafeDoneFromUnknown)

let stats = frame =>
  frame->errorStatsRaw->Nullable.toOption

let doneStats = frame =>
  frame->doneStatsRaw->Nullable.toOption

let doneType = frame =>
  switch frame->doneTypeRaw->Surrealdb_QueryType.parse {
  | Some(value) => value
  | None => throw(Failure(`Unexpected SurrealDB query type: ${frame->doneTypeRaw}`))
  }

let toJsonObject = frame =>
  [
    [("query", JSON.Encode.int(frame->query))],
    switch frame->asValue {
    | Some(valueFrame) =>
      [
        ("frameType", JSON.Encode.string("value")),
        ("value", valueFrame->valueData->Surrealdb_Value.fromUnknown->Surrealdb_Value.toJSON),
        ("isSingle", JSON.Encode.bool(valueFrame->valueIsSingle)),
      ]
    | None =>
      switch frame->asError {
      | Some(errorFrame) =>
        [
          ("frameType", JSON.Encode.string("error")),
          ("error", errorFrame->errorValue->Surrealdb_ServerError.toJSON),
          ...switch errorFrame->stats {
          | Some(value) => [("stats", value->Surrealdb_QueryStats.toJSON)]
          | None => []
          },
        ]
      | None =>
        switch frame->asDone {
        | Some(doneFrame) =>
          [
            ("frameType", JSON.Encode.string("done")),
            ("type", JSON.Encode.string(doneFrame->doneType->Surrealdb_QueryType.toString)),
            ...switch doneFrame->doneStats {
            | Some(value) => [("stats", value->Surrealdb_QueryStats.toJSON)]
            | None => []
            },
          ]
        | None => [("frameType", JSON.Encode.string("frame"))]
        }
      }
    },
  ]
  ->Belt.Array.concatMany
  ->Dict.fromArray

let toJSON = frame =>
  frame->toJsonObject->JSON.Encode.object
