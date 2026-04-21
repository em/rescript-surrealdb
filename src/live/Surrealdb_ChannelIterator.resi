type t<'value>
type result<'value>

let make: unit => t<'value>
let makeWithCleanup: (unit => unit) => t<'value>
let next: t<'value> => promise<result<'value>>
let return_: t<'value> => promise<result<'value>>
let throwRaw: (t<'value>, unknown) => promise<result<'value>>
let submit: (t<'value>, 'value) => unit
let cancel: t<'value> => unit
let done: result<'value> => bool
let valueRaw: result<'value> => Nullable.t<'value>
let asAsyncIterable: t<'value> => Surrealdb_AsyncIterable.t<'value>
let value: result<'value> => option<'value>
let throw_: (t<'value>, unknown) => promise<result<'value>>
