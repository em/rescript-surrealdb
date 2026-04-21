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
  ~method: string=?,
  ~headers: dict<string>=?,
  ~query: dict<string>=?,
  unit,
) => request
let setHeaderRaw: (t, string, Nullable.t<string>) => unit
let invokePath: (t, string) => Surrealdb_ApiPromise.t<Surrealdb_ApiResponse.t>
let invokeRaw: (t, string, request) => Surrealdb_ApiPromise.t<Surrealdb_ApiResponse.t>
let get_: (t, string) => Surrealdb_ApiPromise.t<Surrealdb_ApiResponse.t>
let post_: (t, string) => Surrealdb_ApiPromise.t<Surrealdb_ApiResponse.t>
let postRaw: (t, string, Surrealdb_JsValue.t) => Surrealdb_ApiPromise.t<Surrealdb_ApiResponse.t>
let put_: (t, string) => Surrealdb_ApiPromise.t<Surrealdb_ApiResponse.t>
let putRaw: (t, string, Surrealdb_JsValue.t) => Surrealdb_ApiPromise.t<Surrealdb_ApiResponse.t>
let deleteNoBody: (t, string) => Surrealdb_ApiPromise.t<Surrealdb_ApiResponse.t>
let deleteRaw: (t, string, Surrealdb_JsValue.t) => Surrealdb_ApiPromise.t<Surrealdb_ApiResponse.t>
let patch_: (t, string) => Surrealdb_ApiPromise.t<Surrealdb_ApiResponse.t>
let patchRaw: (t, string, Surrealdb_JsValue.t) => Surrealdb_ApiPromise.t<Surrealdb_ApiResponse.t>
let trace_: (t, string) => Surrealdb_ApiPromise.t<Surrealdb_ApiResponse.t>
let traceRaw: (t, string, Surrealdb_JsValue.t) => Surrealdb_ApiPromise.t<Surrealdb_ApiResponse.t>
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
) => Surrealdb_ApiPromise.t<Surrealdb_ApiResponse.t>
let post: (t, string, ~body: Surrealdb_JsValue.t=?, unit) => Surrealdb_ApiPromise.t<Surrealdb_ApiResponse.t>
let put: (t, string, ~body: Surrealdb_JsValue.t=?, unit) => Surrealdb_ApiPromise.t<Surrealdb_ApiResponse.t>
let delete_: (t, string, ~body: Surrealdb_JsValue.t=?, unit) => Surrealdb_ApiPromise.t<Surrealdb_ApiResponse.t>
let patch: (t, string, ~body: Surrealdb_JsValue.t=?, unit) => Surrealdb_ApiPromise.t<Surrealdb_ApiResponse.t>
let trace: (t, string, ~body: Surrealdb_JsValue.t=?, unit) => Surrealdb_ApiPromise.t<Surrealdb_ApiResponse.t>
