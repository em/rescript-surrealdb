open TestRuntime

external stringToUnknown: string => unknown = "%identity"

let detail = kind => {
  let payload: dict<unknown> = Dict.make()
  payload->Dict.set("kind", stringToUnknown(kind))
  payload
}

let stringField = (entries, key) =>
  switch entries->Dict.get(key) {
  | Some(value) => value->JSON.Decode.string
  | None => None
  }

let boolField = (entries, key) =>
  switch entries->Dict.get(key) {
  | Some(value) => value->JSON.Decode.bool
  | None => None
  }

let objectField = (entries, key) =>
  switch entries->Dict.get(key) {
  | Some(value) => value->JSON.Decode.object
  | None => None
  }

describe("SurrealDB error support", () => {
  test("parseRpcError builds typed validation errors", () => {
    let error = Surrealdb_ServerError.makeRpcErrorObject(
      ~code=(-32000),
      ~message="parse failure",
      ~kind=Surrealdb_ErrorKind.validation,
      ~details=detail("Parse"),
      (),
    )->Surrealdb_ServerError.parseRpcError
    error->Surrealdb_ServerError.asValidation->Option.isSome->Expect.expect->Expect.toBe(true)
    error->Surrealdb_ServerError.kind->Expect.expect->Expect.toBe(Surrealdb_ErrorKind.validation)
    error->Surrealdb_ServerError.code->Expect.expect->Expect.toBe(-32000)
    error->Surrealdb_ServerError.details
    ->Option.map(Surrealdb_ServerError.detailKind)
    ->Expect.expect
    ->Expect.toEqual(Some("Parse"))
    error->Surrealdb_ServerError.asValidation
    ->Option.map(Surrealdb_ServerError.validationIsParseError)
    ->Expect.expect
    ->Expect.toEqual(Some(true))

    let payload =
      error->Surrealdb_ServerError.toJSON->JSON.Decode.object->Option.getOr(Dict.make())
    let details = payload->objectField("details")->Option.getOr(Dict.make())
    (
      payload->stringField("name"),
      payload->stringField("message"),
      payload->stringField("sdkClass"),
      payload->stringField("kind"),
      payload->boolField("isParseError"),
      details->stringField("kind"),
      payload->stringField("stack")->Option.isSome,
    )
    ->Expect.expect
    ->Expect.toEqual((
      Some("ValidationError"),
      Some("parse failure"),
      Some("ValidationError"),
      Some("Validation"),
      Some(true),
      Some("Parse"),
      true,
    ))
  })

  test("version support constants stay callable from the SDK", () => {
    Surrealdb_VersionSupport.isVersionSupported(Surrealdb_VersionSupport.minimumVersion)
    ->Expect.expect
    ->Expect.toBe(true)
    Surrealdb_VersionSupport.isVersionSupported("1.0.0")
    ->Expect.expect
    ->Expect.toBe(false)
  })
})
