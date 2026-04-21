type result = array<unknown>
type t<'value>

let textNoBindingsOn: (Surrealdb_Queryable.t, string) => t<result>
let textWithBindingsOn: (Surrealdb_Queryable.t, string, dict<Surrealdb_JsValue.t>) => t<result>
let boundOn: (Surrealdb_Queryable.t, Surrealdb_BoundQuery.t) => t<result>
let inner: t<'value> => Surrealdb_BoundQuery.t
let json: t<'value> => t<'value>
let collect: t<result> => promise<result>
let collectIndexes: (t<result>, array<int>) => promise<result>
let responses: t<result> => promise<array<Surrealdb_QueryResponse.t>>
let responsesIndexes: (t<result>, array<int>) => promise<array<Surrealdb_QueryResponse.t>>
let stream: t<'value> => Surrealdb_AsyncIterable.t<Surrealdb_Frame.t<unknown>>
let thenResolve: (t<'value>, ('value => 'value)) => promise<'value>
let textOn: (Surrealdb_Queryable.t, string, ~bindings: dict<Surrealdb_JsValue.t>=?, unit) => t<result>
let text: (Surrealdb_Surreal.t, string, ~bindings: dict<Surrealdb_JsValue.t>=?, unit) => t<result>
let runTextOn: (Surrealdb_Queryable.t, string) => promise<result>
let runText: (Surrealdb_Surreal.t, string) => promise<result>
let runBoundOn: (Surrealdb_Queryable.t, Surrealdb_BoundQuery.t) => promise<result>
let runBound: (Surrealdb_Surreal.t, Surrealdb_BoundQuery.t) => promise<result>
let streamTextOn: (Surrealdb_Queryable.t, string) => Surrealdb_AsyncIterable.t<Surrealdb_Frame.t<unknown>>
let streamText: (Surrealdb_Surreal.t, string) => Surrealdb_AsyncIterable.t<Surrealdb_Frame.t<unknown>>
let streamBoundOn: (
  Surrealdb_Queryable.t,
  Surrealdb_BoundQuery.t,
) => Surrealdb_AsyncIterable.t<Surrealdb_Frame.t<unknown>>
let streamBound: (
  Surrealdb_Surreal.t,
  Surrealdb_BoundQuery.t,
) => Surrealdb_AsyncIterable.t<Surrealdb_Frame.t<unknown>>
let resolve: t<'value> => promise<'value>
let statement: (string, dict<Surrealdb_JsValue.t>) => Surrealdb_BoundQuery.t
let runStatementOn: (Surrealdb_Queryable.t, Surrealdb_BoundQuery.t) => promise<result>
let runStatement: (Surrealdb_Surreal.t, Surrealdb_BoundQuery.t) => promise<result>
let streamStatementOn: (
  Surrealdb_Queryable.t,
  Surrealdb_BoundQuery.t,
) => Surrealdb_AsyncIterable.t<Surrealdb_Frame.t<unknown>>
let streamStatement: (
  Surrealdb_Surreal.t,
  Surrealdb_BoundQuery.t,
) => Surrealdb_AsyncIterable.t<Surrealdb_Frame.t<unknown>>
let runStatementTextOn: (Surrealdb_Queryable.t, string) => promise<result>
let runStatementText: (Surrealdb_Surreal.t, string) => promise<result>
let databaseInfoStatement: unit => Surrealdb_BoundQuery.t
let tableInfoStatement: string => Surrealdb_BoundQuery.t
let countAllStatement: string => Surrealdb_BoundQuery.t
let tableStructureStatement: string => Surrealdb_BoundQuery.t
let dbStructureStatement: unit => Surrealdb_BoundQuery.t
