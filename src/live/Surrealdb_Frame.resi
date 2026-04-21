type t<'value>
type ctor
type value<'value>
type error<'value>
type done<'value>

let ctor: ctor
let valueCtor: ctor
let errorCtor: ctor
let doneCtor: ctor
let query: t<'value> => int
let isOf: (t<'value>, int) => bool
let isValue_: t<'value> => bool
let isError_: t<'value> => bool
let isDone_: t<'value> => bool
let isValueOf: (t<'value>, int) => bool
let isErrorOf: (t<'value>, int) => bool
let isDoneOf: (t<'value>, int) => bool
let valueData: value<'value> => 'value
let valueIsSingle: value<'value> => bool
let errorStatsRaw: error<'value> => Nullable.t<Surrealdb_QueryStats.t>
let errorValue: error<'value> => Surrealdb_ServerError.t
let throw_: error<'value> => 'a
let doneStatsRaw: done<'value> => Nullable.t<Surrealdb_QueryStats.t>
let doneType: done<'value> => string
let fromUnknown: unknown => option<t<'value>>
let asValue: t<'value> => option<value<'value>>
let asError: t<'value> => option<error<'value>>
let asDone: t<'value> => option<done<'value>>
let stats: error<'value> => option<Surrealdb_QueryStats.t>
let doneStats: done<'value> => option<Surrealdb_QueryStats.t>
let toJsonObject: t<'value> => dict<JSON.t>
let toJSON: t<'value> => JSON.t
