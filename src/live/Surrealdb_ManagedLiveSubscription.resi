type t
type ctor

let asLiveSubscription: t => Surrealdb_LiveSubscription.t
let ctor: ctor
let fromSubscription: Surrealdb_LiveSubscription.t => option<t>
