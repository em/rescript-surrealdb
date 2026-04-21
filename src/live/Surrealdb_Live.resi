type managed<'value>
type unmanaged

let tableOn: (Surrealdb_Queryable.t, Surrealdb_Table.t) => managed<Surrealdb_JsValue.t>
let ofOn: (Surrealdb_Queryable.t, Surrealdb_Uuid.t) => unmanaged
let diff: managed<'value> => managed<'value>
let fields: (managed<'value>, array<string>) => managed<'value>
let value: (managed<'value>, string) => managed<'value>
let where: (managed<'value>, Surrealdb_Expr.t) => managed<'value>
let fetch: (managed<'value>, array<string>) => managed<'value>
let compile: managed<'value> => Surrealdb_BoundQuery.t
let thenManaged: (
  managed<'value>,
  (Surrealdb_LiveSubscription.t => Surrealdb_LiveSubscription.t),
) => promise<Surrealdb_LiveSubscription.t>
let thenUnmanaged: (
  unmanaged,
  (Surrealdb_LiveSubscription.t => Surrealdb_LiveSubscription.t),
) => promise<Surrealdb_LiveSubscription.t>
let tableNamedOn: (Surrealdb_Queryable.t, string) => managed<Surrealdb_JsValue.t>
let ofIdOn: (Surrealdb_Queryable.t, Surrealdb_Uuid.t) => unmanaged
let awaitManaged: managed<'value> => promise<Surrealdb_LiveSubscription.t>
let awaitUnmanaged: unmanaged => promise<Surrealdb_LiveSubscription.t>
let table: (Surrealdb_Surreal.t, Surrealdb_Table.t) => managed<Surrealdb_JsValue.t>
let of_: (Surrealdb_Surreal.t, Surrealdb_Uuid.t) => unmanaged
