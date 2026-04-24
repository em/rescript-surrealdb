type t
type value
type error
type done

let query: t => int
let isOf: (t, int) => bool
let isValue_: t => bool
let isError_: t => bool
let isDone_: t => bool
let isValueOf: (t, int) => bool
let isErrorOf: (t, int) => bool
let isDoneOf: (t, int) => bool
let fromUnknown: unknown => option<t>
let asValue: t => option<value>
let asError: t => option<error>
let asDone: t => option<done>
let value: value => JSON.t
let valueIsSingle: value => bool
let errorValue: error => Surrealdb_ServerError.t
let throw_: error => 'a
let stats: error => option<Surrealdb_QueryStats.t>
let doneStats: done => option<Surrealdb_QueryStats.t>
let doneType: done => Surrealdb_QueryType.t
let toJsonObject: t => dict<JSON.t>
let toJSON: t => JSON.t
