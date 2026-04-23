type result = array<Surrealdb_Value.t>
type jsonResult = array<JSON.t>
type t<'value>

let textNoBindingsOn: (Surrealdb_Queryable.t, string) => t<result>
let textWithBindingsOn: (Surrealdb_Queryable.t, string, dict<Surrealdb_JsValue.t>) => t<result>
let boundOn: (Surrealdb_Queryable.t, Surrealdb_BoundQuery.t) => t<result>
let inner: t<'value> => Surrealdb_BoundQuery.t
let json: t<'value> => t<jsonResult>
let collect: t<result> => promise<result>
let collectJson: t<jsonResult> => promise<jsonResult>
let collectIndexes: (t<result>, array<int>) => promise<result>
let responses: t<result> => promise<array<Surrealdb_QueryResponse.t>>
let responsesIndexes: (t<result>, array<int>) => promise<array<Surrealdb_QueryResponse.t>>
let stream: t<result> => Surrealdb_AsyncIterable.t<Surrealdb_QueryFrame.t>
let streamJson: t<jsonResult> => Surrealdb_AsyncIterable.t<Surrealdb_JsonFrame.t>
let thenResolve: (t<result>, (result => result)) => promise<result>
let thenResolveJson: (t<jsonResult>, (jsonResult => jsonResult)) => promise<jsonResult>
let textOn: (Surrealdb_Queryable.t, string, ~bindings: dict<Surrealdb_JsValue.t>=?, unit) => t<result>
let text: (Surrealdb_Surreal.t, string, ~bindings: dict<Surrealdb_JsValue.t>=?, unit) => t<result>
let runTextOn: (Surrealdb_Queryable.t, string) => promise<result>
let runText: (Surrealdb_Surreal.t, string) => promise<result>
let runBoundOn: (Surrealdb_Queryable.t, Surrealdb_BoundQuery.t) => promise<result>
let runBound: (Surrealdb_Surreal.t, Surrealdb_BoundQuery.t) => promise<result>
let streamTextOn: (Surrealdb_Queryable.t, string) => Surrealdb_AsyncIterable.t<Surrealdb_QueryFrame.t>
let streamText: (Surrealdb_Surreal.t, string) => Surrealdb_AsyncIterable.t<Surrealdb_QueryFrame.t>
let streamBoundOn: (
  Surrealdb_Queryable.t,
  Surrealdb_BoundQuery.t,
) => Surrealdb_AsyncIterable.t<Surrealdb_QueryFrame.t>
let streamBound: (
  Surrealdb_Surreal.t,
  Surrealdb_BoundQuery.t,
) => Surrealdb_AsyncIterable.t<Surrealdb_QueryFrame.t>
let resolve: t<result> => promise<result>
let resolveJson: t<jsonResult> => promise<jsonResult>
let statement: (string, dict<Surrealdb_JsValue.t>) => Surrealdb_BoundQuery.t
let runStatementOn: (Surrealdb_Queryable.t, Surrealdb_BoundQuery.t) => promise<result>
let runStatement: (Surrealdb_Surreal.t, Surrealdb_BoundQuery.t) => promise<result>
let streamStatementOn: (
  Surrealdb_Queryable.t,
  Surrealdb_BoundQuery.t,
) => Surrealdb_AsyncIterable.t<Surrealdb_QueryFrame.t>
let streamStatement: (
  Surrealdb_Surreal.t,
  Surrealdb_BoundQuery.t,
) => Surrealdb_AsyncIterable.t<Surrealdb_QueryFrame.t>
let runStatementTextOn: (Surrealdb_Queryable.t, string) => promise<result>
let runStatementText: (Surrealdb_Surreal.t, string) => promise<result>
let databaseInfoStatement: unit => Surrealdb_BoundQuery.t
let tableInfoStatement: string => Surrealdb_BoundQuery.t
let countAllStatement: string => Surrealdb_BoundQuery.t
let tableStructureStatement: string => Surrealdb_BoundQuery.t
let dbStructureStatement: unit => Surrealdb_BoundQuery.t
