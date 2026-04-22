open TestRuntime

external toUnknown: 'a => unknown = "%identity"
external dictToUnknown: dict<unknown> => unknown = "%identity"
external nullableToUnknown: Nullable.t<'a> => unknown = "%identity"
external intToUnknown: int => unknown = "%identity"
external floatToUnknown: float => unknown = "%identity"
external boolToUnknown: bool => unknown = "%identity"
external stringToUnknown: string => unknown = "%identity"
@val external symbolForUnknown: string => unknown = "Symbol.for"

let jsonText = value =>
  value->JSON.stringifyAny->Option.getOr("")

describe("SurrealDB error payload surface", () => {
  test("foreign payloads classify primitives, arrays, surreal values, and typed dicts", () => {
    let nestedArray: array<unknown> = [boolToUnknown(true), Surrealdb_Table.make("widgets")->toUnknown]
    let rawDict: dict<unknown> =
      Dict.fromArray([
        ("count", intToUnknown(3)),
        ("label", stringToUnknown("x")),
        ("nested", nestedArray->toUnknown),
      ])
    let bigintValue = Surrealdb_Duration.nanosecondsValue(9)->Surrealdb_Duration.nanoseconds
    let objectPayload = Surrealdb_ErrorPayload.Object(rawDict->Surrealdb_ErrorPayload.classifyDict)

    (
      [
        None->toUnknown->Surrealdb_ErrorPayload.fromUnknown,
        Nullable.null->nullableToUnknown->Surrealdb_ErrorPayload.fromUnknown,
        "alpha"->stringToUnknown->Surrealdb_ErrorPayload.fromUnknown,
        true->boolToUnknown->Surrealdb_ErrorPayload.fromUnknown,
        7.5->floatToUnknown->Surrealdb_ErrorPayload.fromUnknown,
        bigintValue->toUnknown->Surrealdb_ErrorPayload.fromUnknown,
        symbolForUnknown("demo")->Surrealdb_ErrorPayload.fromUnknown,
        (() => ())->toUnknown->Surrealdb_ErrorPayload.fromUnknown,
        [intToUnknown(1), stringToUnknown("two")]->toUnknown->Surrealdb_ErrorPayload.fromUnknown,
        Surrealdb_Table.make("widgets")->toUnknown->Surrealdb_ErrorPayload.fromUnknown,
        rawDict->dictToUnknown->Surrealdb_ErrorPayload.fromUnknown,
        objectPayload,
      ]
      ->Array.map(payload => payload->Surrealdb_ErrorPayload.toJSON->jsonText),
      rawDict
      ->Surrealdb_ErrorPayload.classifyDict
      ->Dict.toArray
      ->Array.map(((key, value)) => (key, value->Surrealdb_ErrorPayload.toJSON->jsonText)),
    )
    ->Expect.expect
    ->Expect.toEqual((
      [
        "{\"foreignPayloadType\":\"undefined\"}",
        "{\"foreignPayloadType\":\"null\"}",
        "{\"foreignPayloadType\":\"string\",\"value\":\"alpha\"}",
        "{\"foreignPayloadType\":\"boolean\",\"value\":true}",
        "{\"foreignPayloadType\":\"number\",\"value\":7.5}",
        "{\"foreignPayloadType\":\"bigint\",\"value\":\"9\"}",
        "{\"foreignPayloadType\":\"symbol\"}",
        "{\"foreignPayloadType\":\"function\"}",
        "{\"foreignPayloadType\":\"array\",\"value\":[{\"foreignPayloadType\":\"number\",\"value\":1},{\"foreignPayloadType\":\"string\",\"value\":\"two\"}]}",
        "{\"foreignPayloadType\":\"surrealValue\",\"value\":\"widgets\"}",
        "{\"foreignPayloadType\":\"object\"}",
        "{\"foreignPayloadType\":\"object\",\"value\":{\"count\":{\"foreignPayloadType\":\"number\",\"value\":3},\"label\":{\"foreignPayloadType\":\"string\",\"value\":\"x\"},\"nested\":{\"foreignPayloadType\":\"array\",\"value\":[{\"foreignPayloadType\":\"boolean\",\"value\":true},{\"foreignPayloadType\":\"surrealValue\",\"value\":\"widgets\"}]}}}",
      ],
      [
        ("count", "{\"foreignPayloadType\":\"number\",\"value\":3}"),
        ("label", "{\"foreignPayloadType\":\"string\",\"value\":\"x\"}"),
        ("nested", "{\"foreignPayloadType\":\"array\",\"value\":[{\"foreignPayloadType\":\"boolean\",\"value\":true},{\"foreignPayloadType\":\"surrealValue\",\"value\":\"widgets\"}]}"),
      ],
    ))
  })
})
