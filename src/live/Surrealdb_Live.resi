type managed
type unmanaged

let tableOn: (Surrealdb_Queryable.t, Surrealdb_Table.t) => managed
let ofOn: (Surrealdb_Queryable.t, Surrealdb_Uuid.t) => unmanaged
let diff: managed => managed
let fields: (managed, array<string>) => managed
let value: (managed, string) => managed
let where: (managed, Surrealdb_Expr.t) => managed
let fetch: (managed, array<string>) => managed
let compile: managed => Surrealdb_BoundQuery.t
let thenManaged: (
  managed,
  (Surrealdb_LiveSubscription.t => Surrealdb_LiveSubscription.t),
) => promise<Surrealdb_LiveSubscription.t>
let thenUnmanaged: (
  unmanaged,
  (Surrealdb_LiveSubscription.t => Surrealdb_LiveSubscription.t),
) => promise<Surrealdb_LiveSubscription.t>
let tableNamedOn: (Surrealdb_Queryable.t, string) => managed
let ofIdOn: (Surrealdb_Queryable.t, Surrealdb_Uuid.t) => unmanaged
let awaitManaged: managed => promise<Surrealdb_LiveSubscription.t>
let awaitUnmanaged: unmanaged => promise<Surrealdb_LiveSubscription.t>
let table: (Surrealdb_Surreal.t, Surrealdb_Table.t) => managed
let of_: (Surrealdb_Surreal.t, Surrealdb_Uuid.t) => unmanaged
