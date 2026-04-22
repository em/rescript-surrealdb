open TestRuntime

external stringToUnknown: string => unknown = "%identity"
external toUnknown: 'a => unknown = "%identity"
external dictToUnknown: dict<unknown> => unknown = "%identity"
@module("surrealdb") @new external makeSurrealError: string => Surrealdb_SurrealError.t = "SurrealError"
@module("surrealdb") @new external makeUnexpectedConnectionError: unknown => Surrealdb_SurrealError.t = "UnexpectedConnectionError"
@module("surrealdb") @new external makePublishError: array<unknown> => Surrealdb_SurrealError.t = "PublishError"
@module("surrealdb") @new external makeUnsupportedFeatureError: Surrealdb_Feature.t => Surrealdb_SurrealError.t = "UnsupportedFeatureError"

let detail = kind => {
  let payload: dict<unknown> = Dict.make()
  payload->Dict.set("kind", stringToUnknown(kind))
  payload
}

let detailWithData = (~kind, ~name) => {
  let nested: dict<unknown> = Dict.make()
  nested->Dict.set("name", stringToUnknown(name))

  let payload: dict<unknown> = Dict.make()
  payload->Dict.set("kind", stringToUnknown(kind))
  payload->Dict.set("details", nested->dictToUnknown)
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

  test("error payloads and top-level classification stay typed", () => {
    let serverError = Surrealdb_ServerError.makeRpcErrorObject(
      ~code=(-32001),
      ~message="invalid parameter",
      ~kind=Surrealdb_ErrorKind.validation,
      ~details=detailWithData(~kind="InvalidParameter", ~name="query"),
      (),
    )->Surrealdb_ServerError.parseRpcError
    let nestedPublishError = makeSurrealError("inner publish failure")
    let publishError = makePublishError([
      stringToUnknown("boom"),
      nestedPublishError->toUnknown,
    ])
    let unexpectedConnection = makeUnexpectedConnectionError(stringToUnknown("socket closed"))
    let unsupportedFeature = makeUnsupportedFeatureError(Surrealdb_Features.liveQueries)

    serverError->toUnknown->Surrealdb_Error.fromUnknown->Expect.expect->Expect.toEqual(Some(Surrealdb_Error.Server(serverError)))
    publishError->toUnknown->Surrealdb_Error.fromUnknown->Expect.expect->Expect.toEqual(Some(Surrealdb_Error.Client(publishError)))
    let baseError = makeSurrealError("plain surreal error")
    baseError->toUnknown->Surrealdb_Error.fromUnknown->Expect.expect->Expect.toEqual(Some(Surrealdb_Error.Base(baseError)))

    publishError
    ->toUnknown
    ->Surrealdb_ClientError.asPublish
    ->Option.map(Surrealdb_ClientError.publishCauses)
    ->Expect.expect
    ->Expect.toEqual(Some([
      Surrealdb_SurrealError.ForeignPayload(Surrealdb_ErrorPayload.String("boom")),
      Surrealdb_SurrealError.Error(nestedPublishError),
    ]))

    unexpectedConnection->Surrealdb_SurrealError.cause->Expect.expect->Expect.toEqual(
      Some(Surrealdb_SurrealError.ForeignPayload(Surrealdb_ErrorPayload.String("socket closed"))),
    )

    unsupportedFeature
    ->toUnknown
    ->Surrealdb_ClientError.asUnsupportedFeature
    ->Option.map(Surrealdb_ClientError.unsupportedFeatureValue)
    ->Expect.expect
    ->Expect.toEqual(Some(Surrealdb_ClientError.Feature(Surrealdb_Features.liveQueries)))

    serverError->Surrealdb_ServerError.details
    ->Option.flatMap(Surrealdb_ServerError.detailData)
    ->Option.flatMap(values => values->Dict.get("name"))
    ->Expect.expect
    ->Expect.toEqual(Some(Surrealdb_ErrorPayload.String("query")))
  })

  test("client-error classifiers stay open at unknown and reject non-errors", () => {
    let publishError = makePublishError([stringToUnknown("boom")])
    let randomPayload: dict<unknown> = Dict.make()
    randomPayload->Dict.set("kind", stringToUnknown("not-a-client-error"))

    (
      publishError->toUnknown->Surrealdb_ClientError.asPublish->Option.isSome,
      randomPayload->dictToUnknown->Surrealdb_ClientError.asPublish->Option.isSome,
      stringToUnknown("boom")->Surrealdb_ClientError.asHttpConnection->Option.isSome,
    )
    ->Expect.expect
    ->Expect.toEqual((true, false, false))
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
