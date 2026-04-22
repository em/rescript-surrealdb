// src/bindings/Surrealdb_QueryFrame.res — typed query-frame wrapper.
// Concern: expose query stream frames with typed Surreal value payloads instead of
// leaking raw unknown frame values through the public query stream surface.
type t
type value
type error
type done

external fromRawFrame: Surrealdb_Frame.t<unknown> => t = "%identity"
external toRawFrame: t => Surrealdb_Frame.t<unknown> = "%identity"
external fromRawValueFrame: Surrealdb_Frame.value<unknown> => value = "%identity"
external toRawValueFrame: value => Surrealdb_Frame.value<unknown> = "%identity"
external fromRawErrorFrame: Surrealdb_Frame.error<unknown> => error = "%identity"
external toRawErrorFrame: error => Surrealdb_Frame.error<unknown> = "%identity"
external fromRawDoneFrame: Surrealdb_Frame.done<unknown> => done = "%identity"
external toRawDoneFrame: done => Surrealdb_Frame.done<unknown> = "%identity"

let query = frame =>
  frame->toRawFrame->Surrealdb_Frame.query

let isOf = (frame, queryIndex) =>
  frame->toRawFrame->Surrealdb_Frame.isOf(queryIndex)

let isValue_ = frame =>
  frame->toRawFrame->Surrealdb_Frame.isValue_

let isError_ = frame =>
  frame->toRawFrame->Surrealdb_Frame.isError_

let isDone_ = frame =>
  frame->toRawFrame->Surrealdb_Frame.isDone_

let isValueOf = (frame, queryIndex) =>
  frame->toRawFrame->Surrealdb_Frame.isValueOf(queryIndex)

let isErrorOf = (frame, queryIndex) =>
  frame->toRawFrame->Surrealdb_Frame.isErrorOf(queryIndex)

let isDoneOf = (frame, queryIndex) =>
  frame->toRawFrame->Surrealdb_Frame.isDoneOf(queryIndex)

let fromUnknown = value =>
  value
  ->Surrealdb_Frame.fromUnknown
  ->Option.map(fromRawFrame)

let asValue = frame =>
  frame->toRawFrame->Surrealdb_Frame.asValue->Option.map(fromRawValueFrame)

let asError = frame =>
  frame->toRawFrame->Surrealdb_Frame.asError->Option.map(fromRawErrorFrame)

let asDone = frame =>
  frame->toRawFrame->Surrealdb_Frame.asDone->Option.map(fromRawDoneFrame)

let value = frame =>
  frame->toRawValueFrame->Surrealdb_Frame.valueData->Surrealdb_Value.fromUnknown

let valueIsSingle = frame =>
  frame->toRawValueFrame->Surrealdb_Frame.valueIsSingle

let errorValue = frame =>
  frame->toRawErrorFrame->Surrealdb_Frame.errorValue

let throw_ = frame =>
  frame->toRawErrorFrame->Surrealdb_Frame.throw_

let stats = frame =>
  frame->toRawErrorFrame->Surrealdb_Frame.stats

let doneStats = frame =>
  frame->toRawDoneFrame->Surrealdb_Frame.doneStats

let doneType = frame =>
  frame->toRawDoneFrame->Surrealdb_Frame.doneType

let toJsonObject = frame =>
  frame->toRawFrame->Surrealdb_Frame.toJsonObject

let toJSON = frame =>
  frame->toRawFrame->Surrealdb_Frame.toJSON
