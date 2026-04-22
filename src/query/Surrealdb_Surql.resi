let text: (array<string>, array<Surrealdb_JsValue.t>) => string
let dateTime: (array<string>, array<Surrealdb_JsValue.t>) => Surrealdb_DateTime.t
let recordId: (array<string>, array<Surrealdb_JsValue.t>) => Surrealdb_StringRecordId.t
let uuid: (array<string>, array<Surrealdb_JsValue.t>) => Surrealdb_Uuid.t
let query: (array<string>, array<Surrealdb_JsValue.t>) => Surrealdb_BoundQuery.t
let toString: Surrealdb_JsValue.t => string
let toSurrealqlString: Surrealdb_JsValue.t => string
