let text: (array<string>, array<unknown>) => string
let dateTime: (array<string>, array<unknown>) => Surrealdb_DateTime.t
let recordId: (array<string>, array<unknown>) => Surrealdb_StringRecordId.t
let uuid: (array<string>, array<unknown>) => Surrealdb_Uuid.t
let query: (array<string>, array<unknown>) => Surrealdb_BoundQuery.t
let toString: unknown => string
let toSurrealqlString: unknown => string
