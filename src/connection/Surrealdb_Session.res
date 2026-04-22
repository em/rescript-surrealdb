// src/bindings/Surrealdb_Session.res — SurrealDB session binding.
// Concern: bind the SurrealSession class from the surrealdb SDK.
// Source: https://surrealdb.com/docs/sdk/javascript/concepts/multiple-sessions —
// sessions can fork, reset, close, switch namespace/database, and begin
// transactions while sharing the underlying connection.
type t
type signinAuth
type recordAccessAuth
type namespaceDatabase

@module("../support/Surrealdb_Interop.js")
external subscribeRaw: (t, string, array<unknown> => unit) => unit => unit = "subscribeEvent"

@module("surrealdb") @scope("SurrealSession")
external ofRaw: (t, Surrealdb_Uuid.t) => t = "of"

external asQueryable: t => Surrealdb_Queryable.t = "%identity"
@get external namespaceRaw: t => Nullable.t<string> = "namespace"
@get external databaseRaw: t => Nullable.t<string> = "database"
@get external accessTokenRaw: t => Nullable.t<string> = "accessToken"
@get external parametersRaw: t => dict<unknown> = "parameters"
@get external sessionRaw: t => Nullable.t<Surrealdb_Uuid.t> = "session"
@get external isValid: t => bool = "isValid"

@send external fork: t => promise<t> = "forkSession"
@send external close: t => promise<unit> = "closeSession"
@send external beginTransaction: t => promise<Surrealdb_Transaction.t> = "beginTransaction"
@send external useCurrent: t => promise<namespaceDatabase> = "use"
@send external useDatabase: (t, namespaceDatabase) => promise<namespaceDatabase> = "use"
@send external reset: t => promise<unit> = "reset"
@send external invalidate: t => promise<unit> = "invalidate"
@send external set: (t, string, Surrealdb_JsValue.t) => promise<unit> = "set"
@send external unset: (t, string) => promise<unit> = "unset"
@send external signupRaw: (t, recordAccessAuth) => promise<Surrealdb_Tokens.t> = "signup"
@send external signinRaw: (t, signinAuth) => promise<Surrealdb_Tokens.t> = "signin"
@send external authenticateTokenRaw: (t, string) => promise<Surrealdb_Tokens.t> = "authenticate"
@send external authenticateTokensRaw: (t, Surrealdb_Tokens.t) => promise<Surrealdb_Tokens.t> = "authenticate"

@obj
external rootAuth: (
  ~username: string,
  ~password: string,
  unit,
) => signinAuth = ""

@obj
external namespaceAuth: (
  ~namespace: string,
  ~username: string,
  ~password: string,
  unit,
) => signinAuth = ""

@obj
external databaseAuth: (
  ~namespace: string,
  ~database: string,
  ~username: string,
  ~password: string,
  unit,
) => signinAuth = ""

@obj
external accessSystemAuth: (
  ~username: string,
  ~password: string,
  ~access: string,
  ~namespace: string=?,
  ~database: string=?,
  unit,
) => signinAuth = ""

@obj
external accessBearerAuth: (
  ~access: string,
  ~key: string,
  ~namespace: string=?,
  ~database: string=?,
  unit,
) => signinAuth = ""

@obj
external makeAccessRecordAuth: (
  ~access: string,
  ~variables: dict<Surrealdb_JsValue.t>,
  ~namespace: string=?,
  ~database: string=?,
  unit,
) => recordAccessAuth = ""

external accessRecordAsSignin: recordAccessAuth => signinAuth = "%identity"

@obj
external makeNamespaceDatabase: (
  ~namespace: Nullable.t<string>=?,
  ~database: Nullable.t<string>=?,
  unit,
) => namespaceDatabase = ""

@get external namespaceValueRaw: namespaceDatabase => Nullable.t<string> = "namespace"
@get external databaseValueRaw: namespaceDatabase => Nullable.t<string> = "database"

let namespace = session =>
  session->namespaceRaw->Nullable.toOption

let database = session =>
  session->databaseRaw->Nullable.toOption

let accessToken = session =>
  session->accessTokenRaw->Nullable.toOption

let subscribe = (session, event, listener) =>
  session->subscribeRaw(event, payload => listener(payload->Array.map(Surrealdb_Value.fromUnknown)))

let parameters = session => {
  let values = Dict.make()
  session->parametersRaw->Dict.toArray->Array.forEach(((key, value)) =>
    values->Dict.set(key, value->Surrealdb_Value.fromUnknown)
  )
  values
}

let sessionId = session =>
  session->sessionRaw->Nullable.toOption

let namespaceValue = value =>
  value->namespaceValueRaw->Nullable.toOption

let databaseValue = value =>
  value->databaseValueRaw->Nullable.toOption

let signup = (session, auth) =>
  session->signupRaw(auth)

let signin = (session, auth) =>
  session->signinRaw(auth)

let signinAccessRecord = (session, auth) =>
  session->signinRaw(auth->accessRecordAsSignin)

let authenticateToken = (session, token) =>
  session->authenticateTokenRaw(token)

let authenticateTokens = (session, tokens) =>
  session->authenticateTokensRaw(tokens)

let of_ = (parent, sessionId) =>
  ofRaw(parent, sessionId)
