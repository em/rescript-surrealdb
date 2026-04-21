type t

let asQueryable: t => Surrealdb_Queryable.t
let commit: t => promise<unit>
let cancel: t => promise<unit>
