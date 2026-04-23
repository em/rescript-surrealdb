type responseMode
type bodyMode
type valueFormat
type jsonFormat
type t<'mode, 'format>

let json: t<'mode, valueFormat> => t<'mode, jsonFormat>
let header: (t<'mode, 'format>, string, string) => t<'mode, 'format>
let query: (t<'mode, 'format>, string, string) => t<'mode, 'format>
let value: t<responseMode, 'format> => t<bodyMode, 'format>
let compile: t<'mode, 'format> => Surrealdb_BoundQuery.t
let stream: t<'mode, valueFormat> => Surrealdb_AsyncIterable.t<Surrealdb_Frame.t<Surrealdb_ApiResponse.t>>
let streamJson: t<'mode, jsonFormat> => Surrealdb_AsyncIterable.t<Surrealdb_Frame.t<Surrealdb_ApiJsonResponse.t>>
let then_: (
  t<responseMode, valueFormat>,
  (Surrealdb_ApiResponse.t => Surrealdb_ApiResponse.t),
) => promise<Surrealdb_ApiResponse.t>
let thenJson: (
  t<responseMode, jsonFormat>,
  (Surrealdb_ApiJsonResponse.t => Surrealdb_ApiJsonResponse.t),
) => promise<Surrealdb_ApiJsonResponse.t>
let thenValue: (
  t<bodyMode, valueFormat>,
  (Surrealdb_Value.t => Surrealdb_Value.t),
) => promise<Surrealdb_Value.t>
let thenValueJson: (t<bodyMode, jsonFormat>, (JSON.t => JSON.t)) => promise<JSON.t>
let resolve: t<responseMode, valueFormat> => promise<Surrealdb_ApiResponse.t>
let resolveJson: t<responseMode, jsonFormat> => promise<Surrealdb_ApiJsonResponse.t>
let awaitValue: t<bodyMode, valueFormat> => promise<Surrealdb_Value.t>
let awaitValueJson: t<bodyMode, jsonFormat> => promise<JSON.t>
