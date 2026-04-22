type t

let close: t => promise<unit>
let ready: t => unit
let featuresSet: t => Set.t<Surrealdb_Feature.t>
let arrayFromSet: Set.t<'a> => array<'a>
let features: t => array<Surrealdb_Feature.t>
