type t
type request

type method =
  | Get
  | Post
  | Put
  | Delete
  | Patch
  | Trace

let encodeMethod: method => string
let onQueryable: Surrealdb_Queryable.t => t
let onQueryableWithPrefix: (Surrealdb_Queryable.t, string) => t
let makeRequest: (
  ~body: Surrealdb_JsValue.t=?,
  ~method: method=?,
  ~headers: dict<string>=?,
  ~query: dict<string>=?,
  unit,
) => request
let setHeaderRaw: (t, string, Nullable.t<string>) => unit
let invokePath: (
  t,
  string,
) => Surrealdb_ApiPromise.t<Surrealdb_ApiPromise.responseMode, Surrealdb_ApiPromise.valueFormat>
let invokeRaw: (
  t,
  string,
  request,
) => Surrealdb_ApiPromise.t<Surrealdb_ApiPromise.responseMode, Surrealdb_ApiPromise.valueFormat>
let get_: (
  t,
  string,
) => Surrealdb_ApiPromise.t<Surrealdb_ApiPromise.responseMode, Surrealdb_ApiPromise.valueFormat>
let post_: (
  t,
  string,
) => Surrealdb_ApiPromise.t<Surrealdb_ApiPromise.responseMode, Surrealdb_ApiPromise.valueFormat>
let postRaw: (
  t,
  string,
  Surrealdb_JsValue.t,
) => Surrealdb_ApiPromise.t<Surrealdb_ApiPromise.responseMode, Surrealdb_ApiPromise.valueFormat>
let put_: (
  t,
  string,
) => Surrealdb_ApiPromise.t<Surrealdb_ApiPromise.responseMode, Surrealdb_ApiPromise.valueFormat>
let putRaw: (
  t,
  string,
  Surrealdb_JsValue.t,
) => Surrealdb_ApiPromise.t<Surrealdb_ApiPromise.responseMode, Surrealdb_ApiPromise.valueFormat>
let deleteNoBody: (
  t,
  string,
) => Surrealdb_ApiPromise.t<Surrealdb_ApiPromise.responseMode, Surrealdb_ApiPromise.valueFormat>
let deleteRaw: (
  t,
  string,
  Surrealdb_JsValue.t,
) => Surrealdb_ApiPromise.t<Surrealdb_ApiPromise.responseMode, Surrealdb_ApiPromise.valueFormat>
let patch_: (
  t,
  string,
) => Surrealdb_ApiPromise.t<Surrealdb_ApiPromise.responseMode, Surrealdb_ApiPromise.valueFormat>
let patchRaw: (
  t,
  string,
  Surrealdb_JsValue.t,
) => Surrealdb_ApiPromise.t<Surrealdb_ApiPromise.responseMode, Surrealdb_ApiPromise.valueFormat>
let trace_: (
  t,
  string,
) => Surrealdb_ApiPromise.t<Surrealdb_ApiPromise.responseMode, Surrealdb_ApiPromise.valueFormat>
let traceRaw: (
  t,
  string,
  Surrealdb_JsValue.t,
) => Surrealdb_ApiPromise.t<Surrealdb_ApiPromise.responseMode, Surrealdb_ApiPromise.valueFormat>
let fromQueryable: Surrealdb_Queryable.t => t
let fromQueryableWithPrefix: (Surrealdb_Queryable.t, string) => t
let setHeader: (t, string, string) => unit
let clearHeader: (t, string) => unit
let invoke: (
  t,
  string,
  ~method: method=?,
  ~body: Surrealdb_JsValue.t=?,
  ~headers: dict<string>=?,
  ~query: dict<string>=?,
  unit,
) => Surrealdb_ApiPromise.t<Surrealdb_ApiPromise.responseMode, Surrealdb_ApiPromise.valueFormat>
let post: (
  t,
  string,
  ~body: Surrealdb_JsValue.t=?,
  unit,
) => Surrealdb_ApiPromise.t<Surrealdb_ApiPromise.responseMode, Surrealdb_ApiPromise.valueFormat>
let put: (
  t,
  string,
  ~body: Surrealdb_JsValue.t=?,
  unit,
) => Surrealdb_ApiPromise.t<Surrealdb_ApiPromise.responseMode, Surrealdb_ApiPromise.valueFormat>
let delete_: (
  t,
  string,
  ~body: Surrealdb_JsValue.t=?,
  unit,
) => Surrealdb_ApiPromise.t<Surrealdb_ApiPromise.responseMode, Surrealdb_ApiPromise.valueFormat>
let patch: (
  t,
  string,
  ~body: Surrealdb_JsValue.t=?,
  unit,
) => Surrealdb_ApiPromise.t<Surrealdb_ApiPromise.responseMode, Surrealdb_ApiPromise.valueFormat>
let trace: (
  t,
  string,
  ~body: Surrealdb_JsValue.t=?,
  unit,
) => Surrealdb_ApiPromise.t<Surrealdb_ApiPromise.responseMode, Surrealdb_ApiPromise.valueFormat>
