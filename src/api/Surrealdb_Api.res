// src/bindings/Surrealdb_Api.res — SurrealDB API binding.
// Concern: bind the SurrealApi class exposed from SurrealQueryable.api().
// Source: https://surrealdb.com/docs/languages/javascript/concepts/invoking-apis —
// SurrealApi supports default headers, invoke(), and method-specific get/post/put/
// delete/patch/trace requests with an optional path prefix.
type t
type request

type method =
  | Get
  | Post
  | Put
  | Delete
  | Patch
  | Trace

let encodeMethod = value =>
  switch value {
  | Get => "get"
  | Post => "post"
  | Put => "put"
  | Delete => "delete"
  | Patch => "patch"
  | Trace => "trace"
  }

@send external onQueryable: Surrealdb_Queryable.t => t = "api"
@send external onQueryableWithPrefix: (Surrealdb_Queryable.t, string) => t = "api"

@obj
external makeRequest: (
  ~body: Surrealdb_JsValue.t=?,
  ~method: string=?,
  ~headers: dict<string>=?,
  ~query: dict<string>=?,
  unit,
) => request = ""

@send external setHeaderRaw: (t, string, Nullable.t<string>) => unit = "header"

@send external invokePath: (t, string) => Surrealdb_ApiPromise.t<Surrealdb_ApiPromise.responseMode, Surrealdb_ApiPromise.valueFormat> = "invoke"
@send external invokeRaw: (t, string, request) => Surrealdb_ApiPromise.t<Surrealdb_ApiPromise.responseMode, Surrealdb_ApiPromise.valueFormat> = "invoke"
@send external get_: (t, string) => Surrealdb_ApiPromise.t<Surrealdb_ApiPromise.responseMode, Surrealdb_ApiPromise.valueFormat> = "get"
@send external post_: (t, string) => Surrealdb_ApiPromise.t<Surrealdb_ApiPromise.responseMode, Surrealdb_ApiPromise.valueFormat> = "post"
@send external postRaw: (t, string, Surrealdb_JsValue.t) => Surrealdb_ApiPromise.t<Surrealdb_ApiPromise.responseMode, Surrealdb_ApiPromise.valueFormat> = "post"
@send external put_: (t, string) => Surrealdb_ApiPromise.t<Surrealdb_ApiPromise.responseMode, Surrealdb_ApiPromise.valueFormat> = "put"
@send external putRaw: (t, string, Surrealdb_JsValue.t) => Surrealdb_ApiPromise.t<Surrealdb_ApiPromise.responseMode, Surrealdb_ApiPromise.valueFormat> = "put"
@send external deleteNoBody: (t, string) => Surrealdb_ApiPromise.t<Surrealdb_ApiPromise.responseMode, Surrealdb_ApiPromise.valueFormat> = "delete"
@send external deleteRaw: (t, string, Surrealdb_JsValue.t) => Surrealdb_ApiPromise.t<Surrealdb_ApiPromise.responseMode, Surrealdb_ApiPromise.valueFormat> = "delete"
@send external patch_: (t, string) => Surrealdb_ApiPromise.t<Surrealdb_ApiPromise.responseMode, Surrealdb_ApiPromise.valueFormat> = "patch"
@send external patchRaw: (t, string, Surrealdb_JsValue.t) => Surrealdb_ApiPromise.t<Surrealdb_ApiPromise.responseMode, Surrealdb_ApiPromise.valueFormat> = "patch"
@send external trace_: (t, string) => Surrealdb_ApiPromise.t<Surrealdb_ApiPromise.responseMode, Surrealdb_ApiPromise.valueFormat> = "trace"
@send external traceRaw: (t, string, Surrealdb_JsValue.t) => Surrealdb_ApiPromise.t<Surrealdb_ApiPromise.responseMode, Surrealdb_ApiPromise.valueFormat> = "trace"

let fromQueryable = queryable =>
  queryable->onQueryable

let fromQueryableWithPrefix = (queryable, prefix) =>
  queryable->onQueryableWithPrefix(prefix)

let setHeader = (api, name, value) =>
  api->setHeaderRaw(name, Nullable.make(value))

let clearHeader = (api, name) =>
  api->setHeaderRaw(name, Nullable.null)

let invoke = (api, path, ~method=?, ~body=?, ~headers=?, ~query=?, ()) => {
  if method == None && body == None && headers == None && query == None {
    api->invokePath(path)
  } else {
  let requestMethod = method->Option.map(encodeMethod)
    api->invokeRaw(path, makeRequest(~method=?requestMethod, ~body?, ~headers?, ~query?, ()))
  }
}

let post = (api, path, ~body=?, ()) =>
  switch body {
  | Some(value) => api->postRaw(path, value)
  | None => api->post_(path)
  }

let put = (api, path, ~body=?, ()) =>
  switch body {
  | Some(value) => api->putRaw(path, value)
  | None => api->put_(path)
  }

let delete_ = (api, path, ~body=?, ()) =>
  switch body {
  | Some(value) => api->deleteRaw(path, value)
  | None => api->deleteNoBody(path)
  }

let patch = (api, path, ~body=?, ()) =>
  switch body {
  | Some(value) => api->patchRaw(path, value)
  | None => api->patch_(path)
  }

let trace = (api, path, ~body=?, ()) =>
  switch body {
  | Some(value) => api->traceRaw(path, value)
  | None => api->trace_(path)
  }
