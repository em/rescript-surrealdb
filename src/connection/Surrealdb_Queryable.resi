type t

let authOn: t => Surrealdb_Auth.t<Surrealdb_Value.t>
let auth: t => Surrealdb_Auth.t<Surrealdb_Value.t>
