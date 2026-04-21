type t

let raw: string => t
let eq: (string, unknown) => t
let eeq: (string, unknown) => t
let ne: (string, unknown) => t
let gt: (string, unknown) => t
let gte: (string, unknown) => t
let lt: (string, unknown) => t
let lte: (string, unknown) => t
let contains: (string, unknown) => t
let containsAny: (string, unknown) => t
let containsAll: (string, unknown) => t
let containsNone: (string, unknown) => t
let inside: (string, unknown) => t
let outside: (string, unknown) => t
let intersects: (string, unknown) => t
let matches: (string, string) => t
let matchesWithRef: (string, string, int) => t
let knn: (string, unknown, int) => t
let knnWithMetric: (string, unknown, int, string) => t
let knnWithEf: (string, unknown, int, int) => t
let between: (string, unknown, unknown) => t
let and_: array<t> => t
let or_: array<t> => t
let not_: t => t
let toBoundQuery: t => Surrealdb_BoundQuery.t
