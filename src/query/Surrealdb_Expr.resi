type t

let raw: string => t
let eq: (string, Surrealdb_JsValue.t) => t
let eeq: (string, Surrealdb_JsValue.t) => t
let ne: (string, Surrealdb_JsValue.t) => t
let gt: (string, Surrealdb_JsValue.t) => t
let gte: (string, Surrealdb_JsValue.t) => t
let lt: (string, Surrealdb_JsValue.t) => t
let lte: (string, Surrealdb_JsValue.t) => t
let contains: (string, Surrealdb_JsValue.t) => t
let containsAny: (string, Surrealdb_JsValue.t) => t
let containsAll: (string, Surrealdb_JsValue.t) => t
let containsNone: (string, Surrealdb_JsValue.t) => t
let inside: (string, Surrealdb_JsValue.t) => t
let outside: (string, Surrealdb_JsValue.t) => t
let intersects: (string, Surrealdb_JsValue.t) => t
let matches: (string, string) => t
let matchesWithRef: (string, string, int) => t
let knn: (string, Surrealdb_JsValue.t, int) => t
let knnWithMetric: (string, Surrealdb_JsValue.t, int, string) => t
let knnWithEf: (string, Surrealdb_JsValue.t, int, int) => t
let between: (string, Surrealdb_JsValue.t, Surrealdb_JsValue.t) => t
let and_: array<t> => t
let or_: array<t> => t
let not_: t => t
let toBoundQuery: t => Surrealdb_BoundQuery.t
