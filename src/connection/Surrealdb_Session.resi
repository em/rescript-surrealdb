type t
type signinAuth
type recordAccessAuth
type namespaceDatabase

let subscribe: (t, string, array<Surrealdb_Value.t> => unit) => unit => unit
let ofRaw: (t, Surrealdb_Uuid.t) => t
let asQueryable: t => Surrealdb_Queryable.t
let namespaceRaw: t => Nullable.t<string>
let databaseRaw: t => Nullable.t<string>
let accessTokenRaw: t => Nullable.t<string>
let sessionRaw: t => Nullable.t<Surrealdb_Uuid.t>
let isValid: t => bool
let fork: t => promise<t>
let close: t => promise<unit>
let beginTransaction: t => promise<Surrealdb_Transaction.t>
let useCurrent: t => promise<namespaceDatabase>
let useDatabase: (t, namespaceDatabase) => promise<namespaceDatabase>
let reset: t => promise<unit>
let invalidate: t => promise<unit>
let set: (t, string, Surrealdb_JsValue.t) => promise<unit>
let unset: (t, string) => promise<unit>
let signupRaw: (t, recordAccessAuth) => promise<Surrealdb_Tokens.t>
let signinRaw: (t, signinAuth) => promise<Surrealdb_Tokens.t>
let authenticateTokenRaw: (t, string) => promise<Surrealdb_Tokens.t>
let authenticateTokensRaw: (t, Surrealdb_Tokens.t) => promise<Surrealdb_Tokens.t>
let rootAuth: (~username: string, ~password: string, unit) => signinAuth
let namespaceAuth: (~namespace: string, ~username: string, ~password: string, unit) => signinAuth
let databaseAuth: (
  ~namespace: string,
  ~database: string,
  ~username: string,
  ~password: string,
  unit,
) => signinAuth
let accessSystemAuth: (
  ~username: string,
  ~password: string,
  ~access: string,
  ~namespace: string=?,
  ~database: string=?,
  unit,
) => signinAuth
let accessBearerAuth: (
  ~access: string,
  ~key: string,
  ~namespace: string=?,
  ~database: string=?,
  unit,
) => signinAuth
let makeAccessRecordAuth: (
  ~access: string,
  ~variables: dict<Surrealdb_JsValue.t>,
  ~namespace: string=?,
  ~database: string=?,
  unit,
) => recordAccessAuth
let accessRecordAsSignin: recordAccessAuth => signinAuth
let makeNamespaceDatabase: (
  ~namespace: Nullable.t<string>=?,
  ~database: Nullable.t<string>=?,
  unit,
) => namespaceDatabase
let namespaceValueRaw: namespaceDatabase => Nullable.t<string>
let databaseValueRaw: namespaceDatabase => Nullable.t<string>
let namespace: t => option<string>
let database: t => option<string>
let accessToken: t => option<string>
let parameters: t => dict<Surrealdb_Value.t>
let sessionId: t => option<Surrealdb_Uuid.t>
let namespaceValue: namespaceDatabase => option<string>
let databaseValue: namespaceDatabase => option<string>
let signup: (t, recordAccessAuth) => promise<Surrealdb_Tokens.t>
let signin: (t, signinAuth) => promise<Surrealdb_Tokens.t>
let signinAccessRecord: (t, recordAccessAuth) => promise<Surrealdb_Tokens.t>
let authenticateToken: (t, string) => promise<Surrealdb_Tokens.t>
let authenticateTokens: (t, Surrealdb_Tokens.t) => promise<Surrealdb_Tokens.t>
let of_: (t, Surrealdb_Uuid.t) => t
