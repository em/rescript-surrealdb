open TestRuntime

external toUnknown: 'a => unknown = "%identity"
external dictToUnknown: dict<unknown> => unknown = "%identity"
external arrayToUnknown: array<unknown> => unknown = "%identity"
external nullableToUnknown: Nullable.t<'a> => unknown = "%identity"
external intToUnknown: int => unknown = "%identity"
external floatToUnknown: float => unknown = "%identity"
external stringToUnknown: string => unknown = "%identity"
@val external symbolForUnknown: string => unknown = "Symbol.for"
@val external nanValue: float = "NaN"
@val external infinityValue: float = "Infinity"
external jsonFromUnknown: unknown => JSON.t = "%identity"
@module("surrealdb") @new external makeRawRecordId: (string, unknown) => Surrealdb_RecordId.t = "RecordId"
@module("../support/SurrealdbTestFixtures.mjs") external functionLeaf: unit => unknown = "functionLeaf"

let jsonText = value =>
  value->JSON.stringifyAny->Option.getOr("")

let dateTimeCompactText = ((seconds, nanos)) => [
  seconds->BigInt.toString,
  nanos->BigInt.toString,
]

let rec recordIdComponentToJSON = value =>
  switch value {
  | Surrealdb_RecordId.Undefined =>
    JSON.Encode.object(Dict.fromArray([("recordIdComponentType", JSON.Encode.string("undefined"))]))
  | Surrealdb_RecordId.Null => JSON.Encode.null
  | Surrealdb_RecordId.Bool(raw) => JSON.Encode.bool(raw)
  | Surrealdb_RecordId.Int(raw) => JSON.Encode.int(raw)
  | Surrealdb_RecordId.Float(raw) => JSON.Encode.float(raw)
  | Surrealdb_RecordId.String(raw) => JSON.Encode.string(raw)
  | Surrealdb_RecordId.BigInt(raw) =>
    JSON.Encode.object(
      Dict.fromArray([
        ("recordIdComponentType", JSON.Encode.string("bigint")),
        ("value", JSON.Encode.string(raw->BigInt.toString)),
      ]),
    )
  | Surrealdb_RecordId.ValueClass(raw) => raw->Surrealdb_ValueClass.toJSON->jsonFromUnknown
  | Surrealdb_RecordId.Array(raw) => raw->Array.map(recordIdComponentToJSON)->JSON.Encode.array
  | Surrealdb_RecordId.Object(raw) =>
    let result = Dict.make()
    raw->Dict.toArray->Array.forEach(((key, item)) => result->Dict.set(key, item->recordIdComponentToJSON))
    JSON.Encode.object(result)
  }

let recordIdComponentArrayText = values =>
  values->Array.map(recordIdComponentToJSON)->JSON.Encode.array->jsonText

let recordIdComponentObjectText = values => {
  let json = Dict.make()
  values->Dict.toArray->Array.forEach(((key, value)) => json->Dict.set(key, value->recordIdComponentToJSON))
  json->JSON.Encode.object->jsonText
}

let recordIdValueText = value =>
  switch value {
  | Surrealdb_RecordId.StringId(raw) => `string:${raw}`
  | Surrealdb_RecordId.NumberId(raw) => `number:${raw->Float.toString}`
  | Surrealdb_RecordId.UuidId(raw) => `uuid:${raw->Surrealdb_Uuid.toString}`
  | Surrealdb_RecordId.BigIntId(raw) => `bigint:${raw->BigInt.toString}`
  | Surrealdb_RecordId.ArrayId(raw) => `array:${raw->recordIdComponentArrayText}`
  | Surrealdb_RecordId.ObjectId(raw) => `object:${raw->recordIdComponentObjectText}`
  }

describe("SurrealDB value surface", () => {
  test("value classification keeps numeric edge cases honest", () => {
    let nanClassified = floatToUnknown(nanValue)->Surrealdb_Value.fromUnknown
    let positiveInfinityClassified = floatToUnknown(infinityValue)->Surrealdb_Value.fromUnknown
    let negativeInfinityClassified = floatToUnknown(-1.0 *. infinityValue)->Surrealdb_Value.fromUnknown
    let lowerBoundClassified = floatToUnknown(-2147483648.0)->Surrealdb_Value.fromUnknown
    let upperBoundClassified = floatToUnknown(2147483647.0)->Surrealdb_Value.fromUnknown
    let tooLargeClassified = floatToUnknown(2147483648.0)->Surrealdb_Value.fromUnknown

    (
      switch nanClassified {
      | Float(value) => Float.isNaN(value)
      | _ => false
      },
      switch positiveInfinityClassified {
      | Float(value) => value == infinityValue
      | _ => false
      },
      switch negativeInfinityClassified {
      | Float(value) => value == -1.0 *. infinityValue
      | _ => false
      },
      switch lowerBoundClassified {
      | Int(value) => value == -2147483648
      | _ => false
      },
      switch upperBoundClassified {
      | Int(value) => value == 2147483647
      | _ => false
      },
      switch tooLargeClassified {
      | Float(value) => value == 2147483648.0
      | _ => false
      },
    )
    ->Expect.expect
    ->Expect.toEqual((true, true, true, true, true, true))
  })

  test("decimal and duration wrappers stay callable through the installed runtime", () => {
    let decimal = Surrealdb_Decimal.fromString("12.34")
    let decimalScientific = Surrealdb_Decimal.fromScientificNotation("1.234e1")
    let decimalFromFloat = Surrealdb_Decimal.fromFloat(12.34)
    let wholeDecimal = Surrealdb_Decimal.fromString("12")
    let negativeDecimal = Surrealdb_Decimal.fromString("-12.34")
    let duration = Surrealdb_Duration.fromString("1h30m15s")
    let durationFromCompact = duration->Surrealdb_Duration.toCompact->Surrealdb_Duration.fromCompact
    let durationFromBigInt = duration->Surrealdb_Duration.nanoseconds->Surrealdb_Duration.fromBigInt
    let durationFromParsed = Surrealdb_Duration.parseString("1h30m15s")->Surrealdb_Duration.fromCompact
    let measured = Surrealdb_Duration.measure()()

    (
      decimal->Surrealdb_Decimal.toString,
      decimal->Surrealdb_Decimal.toJSON,
      decimalScientific->Surrealdb_Decimal.toString,
      decimalFromFloat->Surrealdb_Decimal.toString,
      wholeDecimal->Surrealdb_Decimal.toBigInt->BigInt.toString,
      decimal->Surrealdb_Decimal.add(Surrealdb_Decimal.fromString("0.66"))->Surrealdb_Decimal.toString,
      decimal->Surrealdb_Decimal.sub(Surrealdb_Decimal.fromString("2.34"))->Surrealdb_Decimal.toString,
      decimal->Surrealdb_Decimal.mul(Surrealdb_Decimal.fromString("2"))->Surrealdb_Decimal.toString,
      decimal->Surrealdb_Decimal.div(Surrealdb_Decimal.fromString("2"))->Surrealdb_Decimal.toString,
      decimal->Surrealdb_Decimal.mod(Surrealdb_Decimal.fromString("2"))->Surrealdb_Decimal.toString,
      negativeDecimal->Surrealdb_Decimal.abs->Surrealdb_Decimal.toString,
      decimal->Surrealdb_Decimal.neg->Surrealdb_Decimal.toString,
      Surrealdb_Decimal.fromString("0")->Surrealdb_Decimal.isZero,
      Surrealdb_Decimal.fromString("-1")->Surrealdb_Decimal.isNegative,
      decimal->Surrealdb_Decimal.compare(Surrealdb_Decimal.fromString("12.35")),
      decimal->Surrealdb_Decimal.round(1)->Surrealdb_Decimal.toString,
      decimal->Surrealdb_Decimal.toFixed(1),
      decimal->Surrealdb_Decimal.toFloat,
      decimal->Surrealdb_Decimal.toScientific,
      decimal->Surrealdb_Decimal.intPart->BigInt.toString,
      decimal->Surrealdb_Decimal.fracPart->BigInt.toString,
      decimal->Surrealdb_Decimal.scale,
      Surrealdb_Decimal.isInstance(decimal->toUnknown),
      decimal->toUnknown->Surrealdb_Decimal.fromUnknown->Option.isSome,
      duration->Surrealdb_Duration.toString,
      duration->Surrealdb_Duration.toJSON,
      durationFromCompact->Surrealdb_Duration.toString,
      durationFromBigInt->Surrealdb_Duration.toString,
      durationFromParsed->Surrealdb_Duration.toString,
      duration->Surrealdb_Duration.toCompact->Array.map(value => value->BigInt.toString),
      duration->Surrealdb_Duration.nanoseconds->BigInt.toString,
      duration->Surrealdb_Duration.microseconds->BigInt.toString,
      duration->Surrealdb_Duration.milliseconds->BigInt.toString,
      duration->Surrealdb_Duration.seconds->BigInt.toString,
      duration->Surrealdb_Duration.minutes->BigInt.toString,
      duration->Surrealdb_Duration.hours->BigInt.toString,
      duration->Surrealdb_Duration.days->BigInt.toString,
      duration->Surrealdb_Duration.weeks->BigInt.toString,
      duration->Surrealdb_Duration.years->BigInt.toString,
      duration->Surrealdb_Duration.add(Surrealdb_Duration.fromString("45s"))->Surrealdb_Duration.toString,
      duration->Surrealdb_Duration.sub(Surrealdb_Duration.fromString("15s"))->Surrealdb_Duration.toString,
      duration->Surrealdb_Duration.mulByInt(2)->Surrealdb_Duration.toString,
      duration->Surrealdb_Duration.mulByBigInt(2n)->Surrealdb_Duration.toString,
      duration->Surrealdb_Duration.divByDuration(Surrealdb_Duration.fromString("15s"))->BigInt.toString,
      duration->Surrealdb_Duration.divByInt(3)->Surrealdb_Duration.toString,
      duration->Surrealdb_Duration.divByBigInt(3n)->Surrealdb_Duration.toString,
      duration->Surrealdb_Duration.mod(Surrealdb_Duration.fromString("1h"))->Surrealdb_Duration.toString,
      Surrealdb_Duration.parseFloat("1.5s")->Surrealdb_Duration.toString,
      [
        Surrealdb_Duration.nanosecondsValue(1)->Surrealdb_Duration.toString,
        Surrealdb_Duration.microsecondsValue(1)->Surrealdb_Duration.toString,
        Surrealdb_Duration.millisecondsValue(1)->Surrealdb_Duration.toString,
        Surrealdb_Duration.secondsValue(1)->Surrealdb_Duration.toString,
        Surrealdb_Duration.minutesValue(1)->Surrealdb_Duration.toString,
        Surrealdb_Duration.hoursValue(1)->Surrealdb_Duration.toString,
        Surrealdb_Duration.daysValue(1)->Surrealdb_Duration.toString,
        Surrealdb_Duration.weeksValue(1)->Surrealdb_Duration.toString,
        Surrealdb_Duration.yearsValue(1)->Surrealdb_Duration.toString,
      ],
      Surrealdb_Duration.isInstance(measured->toUnknown),
      measured->toUnknown->Surrealdb_Duration.fromUnknown->Option.isSome,
    )
    ->Expect.expect
    ->Expect.toEqual((
      "12.34",
      "12.34",
      "12.34",
      "12.34",
      "12",
      "13",
      "10",
      "24.68",
      "6.17",
      "0.34",
      "12.34",
      "-12.34",
      true,
      true,
      -1,
      "12.3",
      "12.3",
      12.34,
      "1.234e1",
      "12",
      "34",
      2,
      true,
      true,
      "1h30m15s",
      "1h30m15s",
      "1h30m15s",
      "",
      "1h30m15s",
      ["5415"],
      "5415000000000",
      "5415000000",
      "5415000",
      "5415",
      "90",
      "1",
      "0",
      "0",
      "0",
      "1h31m",
      "1h30m",
      "3h30s",
      "3h30s",
      "361",
      "30m5s",
      "30m5s",
      "30m15s",
      "1s500ms",
      ["1ns", "1us", "1ms", "1s", "1m", "1h", "1d", "1w", "1y"],
      true,
      true,
    ))
  })

  test("datetime, uuid, file, table, record-id, and range wrappers stay typed", () => {
    let dateTime = Surrealdb_DateTime.fromString("2024-01-02T03:04:05Z")
    let dateTimeFromCompact = dateTime->Surrealdb_DateTime.toCompact->Surrealdb_DateTime.fromCompact
    let dateTimeFromMilliseconds =
      dateTime->Surrealdb_DateTime.milliseconds->Surrealdb_DateTime.fromMilliseconds
    let dateTimeFromBigInt = dateTime->Surrealdb_DateTime.nanoseconds->Surrealdb_DateTime.fromBigInt
    let dateTimeFromDate = dateTime->Surrealdb_DateTime.toDate->Surrealdb_DateTime.fromDate
    let uuid = Surrealdb_Uuid.fromString("018cc251-4f5c-7def-b4c6-000000000001")
    let uuidFromBuffer = uuid->Surrealdb_Uuid.toBuffer->Surrealdb_Uuid.fromBuffer
    let uuidFromUint8Array = uuid->Surrealdb_Uuid.toUint8Array->Surrealdb_Uuid.fromUint8Array
    let table = Surrealdb_Table.make("widgets")
    let fileRef = Surrealdb_FileRef.make("bucket", "key/path")
    let stringRecordId = Surrealdb_RecordId.make("widgets", "alpha")
    let numericRecordId = Surrealdb_RecordId.makeWithNumericId("widgets", 5)
    let numberRecordId = Surrealdb_RecordId.makeWithNumberId("widgets", 5.5)
    let uuidRecordId = Surrealdb_RecordId.makeWithUuidId("widgets", uuid)
    let bigintRecordId = Surrealdb_RecordId.makeWithBigIntId("widgets", 7n)
    let arrayRecordId =
      Surrealdb_RecordId.makeWithIdValue(
        "widgets",
        Surrealdb_RecordId.ArrayId([Surrealdb_RecordId.Int(1), Surrealdb_RecordId.String("two")]),
      )
    let objectRecordId =
      Surrealdb_RecordId.makeFromTableWithIdValue(
        table,
        Surrealdb_RecordId.ObjectId(Dict.fromArray([("slug", Surrealdb_RecordId.String("demo"))])),
      )
    let stringId = Surrealdb_StringRecordId.fromString("widgets:alpha")
    let stringIdFromRecord = Surrealdb_StringRecordId.fromRecordId(stringRecordId)
    let stringIdFromString = Surrealdb_StringRecordId.fromStringRecordId(stringId)
    let begin = Surrealdb_RangeBound.included(Surrealdb_RangeBound.String("widgets"))
    let end_ =
      Surrealdb_RangeBound.excluded(
        Surrealdb_RangeBound.Object(
          Dict.fromArray([
            ("count", Surrealdb_RangeBound.Int(3)),
            ("label", Surrealdb_RangeBound.String("x")),
          ]),
        ),
      )
    let range = Surrealdb_Range.make(~begin, ~end=end_, ())
    let recordIdRange =
      Surrealdb_RecordIdRange.make(
        ~table="widgets",
        ~begin=Surrealdb_RangeBound.included(Surrealdb_RangeBound.String("a")),
        ~end=Surrealdb_RangeBound.excluded(Surrealdb_RangeBound.String("z")),
        (),
      )

    (
      dateTime->Surrealdb_DateTime.toString,
      dateTime->Surrealdb_DateTime.toJSON,
      dateTime->Surrealdb_DateTime.toISOString,
      dateTimeFromCompact->Surrealdb_DateTime.toString,
      Surrealdb_DateTime.isInstance(dateTimeFromMilliseconds->toUnknown),
      Surrealdb_DateTime.isInstance(dateTimeFromBigInt->toUnknown),
      dateTimeFromDate->Surrealdb_DateTime.toString,
      dateTime->Surrealdb_DateTime.toCompact->dateTimeCompactText,
      dateTime->Surrealdb_DateTime.nanoseconds->BigInt.toString,
      dateTime->Surrealdb_DateTime.microseconds->BigInt.toString,
      dateTime->Surrealdb_DateTime.milliseconds,
      dateTime->Surrealdb_DateTime.seconds,
      dateTime->Surrealdb_DateTime.add(Surrealdb_Duration.fromString("1h"))->Surrealdb_DateTime.toISOString,
      dateTime->Surrealdb_DateTime.sub(Surrealdb_Duration.fromString("4m5s"))->Surrealdb_DateTime.toISOString,
      dateTime
      ->Surrealdb_DateTime.diff(Surrealdb_DateTime.fromString("2024-01-02T03:00:00Z"))
      ->Surrealdb_Duration.toString,
      dateTime->Surrealdb_DateTime.compare(Surrealdb_DateTime.fromString("2024-01-02T03:04:06Z")),
      Surrealdb_DateTime.parseString("2024-01-02T03:04:05Z")->dateTimeCompactText,
      Surrealdb_DateTime.epoch()->Surrealdb_DateTime.toISOString,
      Surrealdb_DateTime.fromEpochNanoseconds(dateTime->Surrealdb_DateTime.nanoseconds)->Surrealdb_DateTime.toISOString,
      Surrealdb_DateTime.fromEpochMicroseconds(dateTime->Surrealdb_DateTime.microseconds)->Surrealdb_DateTime.toISOString,
      Surrealdb_DateTime.fromEpochMilliseconds(dateTime->Surrealdb_DateTime.milliseconds)->Surrealdb_DateTime.toISOString,
      Surrealdb_DateTime.fromEpochSeconds(dateTime->Surrealdb_DateTime.seconds)->Surrealdb_DateTime.toISOString,
      Surrealdb_DateTime.isInstance(dateTime->toUnknown),
      dateTime->toUnknown->Surrealdb_DateTime.fromUnknown->Option.isSome,
      Surrealdb_DateTime.nowValue()->toUnknown->Surrealdb_DateTime.fromUnknown->Option.isSome,
      uuid->Surrealdb_Uuid.toString,
      uuid->Surrealdb_Uuid.toJSON,
      uuid->Surrealdb_Uuid.bytesLength,
      uuid->Surrealdb_Uuid.bufferByteLength,
      uuidFromBuffer->Surrealdb_Uuid.toString,
      uuidFromUint8Array->Surrealdb_Uuid.toString,
      Surrealdb_Uuid.isInstance(uuid->toUnknown),
      uuid->toUnknown->Surrealdb_Uuid.fromUnknown->Option.isSome,
      Surrealdb_Uuid.v4()->Surrealdb_Uuid.bytesLength,
      Surrealdb_Uuid.v7()->Surrealdb_Uuid.bytesLength,
      table->Surrealdb_Table.name,
      table->Surrealdb_Table.toString,
      table->Surrealdb_Table.toJSON,
      Surrealdb_Table.isInstance(table->toUnknown),
      table->toUnknown->Surrealdb_Table.fromUnknown->Option.isSome,
      fileRef->Surrealdb_FileRef.bucket,
      fileRef->Surrealdb_FileRef.key,
      fileRef->Surrealdb_FileRef.toString,
      fileRef->Surrealdb_FileRef.toJSON,
      Surrealdb_FileRef.isInstance(fileRef->toUnknown),
      fileRef->toUnknown->Surrealdb_FileRef.fromUnknown->Option.isSome,
      [
        stringRecordId->Surrealdb_RecordId.tableName,
        numericRecordId->Surrealdb_RecordId.tableName,
        numberRecordId->Surrealdb_RecordId.tableName,
        uuidRecordId->Surrealdb_RecordId.tableName,
        bigintRecordId->Surrealdb_RecordId.tableName,
        arrayRecordId->Surrealdb_RecordId.tableName,
        objectRecordId->Surrealdb_RecordId.tableName,
      ],
      [
        stringRecordId->Surrealdb_RecordId.idValue->Option.map(recordIdValueText),
        numericRecordId->Surrealdb_RecordId.idValue->Option.map(recordIdValueText),
        numberRecordId->Surrealdb_RecordId.idValue->Option.map(recordIdValueText),
        uuidRecordId->Surrealdb_RecordId.idValue->Option.map(recordIdValueText),
        bigintRecordId->Surrealdb_RecordId.idValue->Option.map(recordIdValueText),
        arrayRecordId->Surrealdb_RecordId.idValue->Option.map(recordIdValueText),
        objectRecordId->Surrealdb_RecordId.idValue->Option.map(recordIdValueText),
      ],
      [
        stringRecordId->Surrealdb_RecordId.toString,
        numericRecordId->Surrealdb_RecordId.toString,
        numberRecordId->Surrealdb_RecordId.toString,
        uuidRecordId->Surrealdb_RecordId.toString,
        bigintRecordId->Surrealdb_RecordId.toString,
        arrayRecordId->Surrealdb_RecordId.toString,
        objectRecordId->Surrealdb_RecordId.toString,
      ],
      Surrealdb_RecordId.isInstance(stringRecordId->toUnknown),
      stringRecordId->toUnknown->Surrealdb_RecordId.fromUnknown->Option.isSome,
      [
        stringId->Surrealdb_StringRecordId.toString,
        stringIdFromRecord->Surrealdb_StringRecordId.toString,
        stringIdFromString->Surrealdb_StringRecordId.toString,
      ],
      Surrealdb_StringRecordId.isInstance(stringId->toUnknown),
      stringId->toUnknown->Surrealdb_StringRecordId.fromUnknown->Option.isSome,
      begin->Surrealdb_RangeBound.kind,
      end_->Surrealdb_RangeBound.kind,
      begin->Surrealdb_RangeBound.isIncluded,
      end_->Surrealdb_RangeBound.isExcluded,
      begin->Surrealdb_RangeBound.value->Surrealdb_BoundValue.toText,
      begin->Surrealdb_RangeBound.value->Surrealdb_BoundValue.toJSON->jsonText,
      end_->Surrealdb_RangeBound.value->Surrealdb_BoundValue.toText,
      end_->Surrealdb_RangeBound.value->Surrealdb_BoundValue.toJSON->jsonText,
      Surrealdb_RangeBound.isInstance(begin->toUnknown),
      begin->toUnknown->Surrealdb_RangeBound.fromUnknown->Option.isSome,
      range->Surrealdb_Range.toString,
      range->Surrealdb_Range.toJSON,
      range->Surrealdb_Range.begin->Option.map(bound => bound->Surrealdb_RangeBound.value->Surrealdb_BoundValue.toText),
      range->Surrealdb_Range.end_->Option.map(bound => bound->Surrealdb_RangeBound.value->Surrealdb_BoundValue.toText),
      Surrealdb_Range.isInstance(range->toUnknown),
      range->toUnknown->Surrealdb_Range.fromUnknown->Option.isSome,
      recordIdRange->Surrealdb_RecordIdRange.table->Surrealdb_Table.name,
      recordIdRange->Surrealdb_RecordIdRange.toString,
      recordIdRange->Surrealdb_RecordIdRange.toJSON,
      recordIdRange
      ->Surrealdb_RecordIdRange.begin
      ->Option.map(bound => bound->Surrealdb_RangeBound.value->Surrealdb_BoundValue.toText),
      recordIdRange
      ->Surrealdb_RecordIdRange.end_
      ->Option.map(bound => bound->Surrealdb_RangeBound.value->Surrealdb_BoundValue.toText),
      Surrealdb_RecordIdRange.isInstance(recordIdRange->toUnknown),
      recordIdRange->toUnknown->Surrealdb_RecordIdRange.fromUnknown->Option.isSome,
    )
    ->Expect.expect
    ->Expect.toEqual((
      "2024-01-02T03:04:05.000Z",
      "2024-01-02T03:04:05.000Z",
      "2024-01-02T03:04:05.000Z",
      "2024-01-02T03:04:05.000Z",
      true,
      true,
      "2024-01-02T03:04:05.000Z",
      ["1704164645", "0"],
      "1704164645000000000",
      "1704164645000000",
      1704164645000.0,
      1704164645.0,
      "2024-01-02T04:04:05.000Z",
      "2024-01-02T03:00:00.000Z",
      "4m5s",
      -1,
      ["1704164645", "0"],
      "1970-01-01T00:00:00.000Z",
      "2024-01-02T03:04:05.000Z",
      "2024-01-02T03:04:05.000Z",
      "2024-01-02T03:04:05.000Z",
      "2024-01-02T03:04:05.000Z",
      true,
      true,
      true,
      "018cc251-4f5c-7def-b4c6-000000000001",
      "018cc251-4f5c-7def-b4c6-000000000001",
      16,
      16,
      "018cc251-4f5c-7def-b4c6-000000000001",
      "018cc251-4f5c-7def-b4c6-000000000001",
      true,
      true,
      16,
      16,
      "widgets",
      "widgets",
      "widgets",
      true,
      true,
      "bucket",
      "/key/path",
      "bucket:/key/path",
      "bucket:/key/path",
      true,
      true,
      ["widgets", "widgets", "widgets", "widgets", "widgets", "widgets", "widgets"],
      [
        Some("string:alpha"),
        Some("number:5"),
        Some("number:5.5"),
        Some("uuid:018cc251-4f5c-7def-b4c6-000000000001"),
        Some("bigint:7"),
        Some("array:[1,\"two\"]"),
        Some("object:{\"slug\":\"demo\"}"),
      ],
      [
        "widgets:alpha",
        "widgets:5",
        "widgets:5.5",
        "widgets:u\"018cc251-4f5c-7def-b4c6-000000000001\"",
        "widgets:7",
        "widgets:[ 1, s\"two\" ]",
        "widgets:{ \"slug\": s\"demo\" }",
      ],
      true,
      true,
      ["widgets:alpha", "widgets:alpha", "widgets:alpha"],
      true,
      true,
      Surrealdb_RangeBound.Include,
      Surrealdb_RangeBound.Exclude,
      true,
      true,
      "widgets",
      "\"widgets\"",
      "count: 3; label: x",
      "{\"count\":3,\"label\":\"x\"}",
      true,
      true,
      "widgets..{ \"count\": 3, \"label\": s\"x\" }",
      "widgets..{ \"count\": 3, \"label\": s\"x\" }",
      Some("widgets"),
      Some("count: 3; label: x"),
      true,
      true,
      "widgets",
      "widgets:a..z",
      "widgets:a..z",
      Some("a"),
      Some("z"),
      true,
      true,
    ))
  })

  test("record id supported subset keeps nested value classes and excludes unsupported function leaves", () => {
    let dateTimeValueClass =
      Surrealdb_DateTime.fromString("2024-01-02T03:04:05Z")
      ->toUnknown
      ->Surrealdb_ValueClass.fromUnknown
      ->Option.getOrThrow
    let tableValueClass =
      Surrealdb_Table.make("orders")->toUnknown->Surrealdb_ValueClass.fromUnknown->Option.getOrThrow
    let nestedValueClassRecordId =
      Surrealdb_RecordId.makeWithIdValue(
        "widgets",
        Surrealdb_RecordId.ObjectId(
          Dict.fromArray([
            ("when", Surrealdb_RecordId.ValueClass(dateTimeValueClass)),
            (
              "nested",
              Surrealdb_RecordId.Array([
                Surrealdb_RecordId.Int(1),
                Surrealdb_RecordId.BigInt(2n),
                Surrealdb_RecordId.ValueClass(tableValueClass),
              ]),
            ),
          ]),
        ),
      )
    let unsupportedLeafRecordId =
      makeRawRecordId("widgets", [functionLeaf()]->arrayToUnknown)

    (
      nestedValueClassRecordId->Surrealdb_RecordId.toString,
      nestedValueClassRecordId->Surrealdb_RecordId.idValue->Option.map(recordIdValueText),
      unsupportedLeafRecordId->Surrealdb_RecordId.toString->String.startsWith("widgets:["),
      unsupportedLeafRecordId->Surrealdb_RecordId.toString->String.includes("rawFunctionLeaf"),
      unsupportedLeafRecordId->Surrealdb_RecordId.idValue->Option.isSome,
    )
    ->Expect.expect
    ->Expect.toEqual((
      "widgets:{ \"when\": d\"2024-01-02T03:04:05.000Z\", \"nested\": [ 1, 2, orders ] }",
      Some("object:{\"when\":\"2024-01-02T03:04:05.000Z\",\"nested\":[1,{\"recordIdComponentType\":\"bigint\",\"value\":\"2\"},\"orders\"]}"),
      true,
      true,
      false,
    ))
  })

  test("bound value classification keeps integer boundaries honest", () => {
    (
      switch floatToUnknown(-2147483648.0)->Surrealdb_BoundValue.fromUnknown {
      | Int(value) => value == -2147483648
      | _ => false
      },
      switch floatToUnknown(2147483647.0)->Surrealdb_BoundValue.fromUnknown {
      | Int(value) => value == 2147483647
      | _ => false
      },
      switch floatToUnknown(2147483648.0)->Surrealdb_BoundValue.fromUnknown {
      | Float(value) => value == 2147483648.0
      | _ => false
      },
    )
    ->Expect.expect
    ->Expect.toEqual((true, true, true))
  })

  test("geometry and bound-value wrappers preserve runtime classification", () => {
    let point =
      Surrealdb_GeometryPoint.make(
        ~longitude=Surrealdb_GeometryPoint.Float(1.0),
        ~latitude=Surrealdb_GeometryPoint.Float(2.0),
      )
    let pointDecimal =
      Surrealdb_GeometryPoint.make(
        ~longitude=Surrealdb_GeometryPoint.Decimal(Surrealdb_Decimal.fromString("1")),
        ~latitude=Surrealdb_GeometryPoint.Decimal(Surrealdb_Decimal.fromString("2")),
      )
    let secondPoint =
      Surrealdb_GeometryPoint.make(
        ~longitude=Surrealdb_GeometryPoint.Float(3.0),
        ~latitude=Surrealdb_GeometryPoint.Float(4.0),
      )
    let line = Surrealdb_GeometryLine.make(~first=point, ~second=secondPoint)
    line->Surrealdb_GeometryLine.close
    let polygon = Surrealdb_GeometryPolygon.make(~outerBoundary=line)
    let multiPoint = Surrealdb_GeometryMultiPoint.make(~first=point, ~rest=[secondPoint])
    let multiLine = Surrealdb_GeometryMultiLine.make(~first=line)
    let multiPolygon = Surrealdb_GeometryMultiPolygon.make(~first=polygon)
    let pointGeometry = point->Surrealdb_GeometryPoint.asGeometry
    let collection =
      Surrealdb_GeometryCollection.make(
        ~first=pointGeometry,
        ~rest=[line->Surrealdb_GeometryLine.asGeometry, polygon->Surrealdb_GeometryPolygon.asGeometry],
      )
    let boundObject: dict<unknown> =
      Dict.fromArray([
        ("count", intToUnknown(3)),
        ("label", stringToUnknown("x")),
      ])
    let boundArray: array<unknown> = [intToUnknown(1), stringToUnknown("two")]
    let bigintValue = Surrealdb_Duration.nanosecondsValue(9)->Surrealdb_Duration.nanoseconds

    (
      point->Surrealdb_GeometryPoint.coordinates,
      pointDecimal->Surrealdb_GeometryPoint.coordinates,
      point->Surrealdb_GeometryPoint.toJSON->jsonText,
      point->Surrealdb_GeometryPoint.clone->Surrealdb_GeometryPoint.equals(point->toUnknown),
      point->Surrealdb_GeometryPoint.matches(pointGeometry),
      Surrealdb_GeometryPoint.isInstance(point->toUnknown),
      point->toUnknown->Surrealdb_GeometryPoint.fromUnknown->Option.isSome,
      pointGeometry->Surrealdb_Geometry.toJSON->jsonText,
      pointGeometry->Surrealdb_Geometry.clone->Surrealdb_Geometry.equals(pointGeometry->toUnknown),
      pointGeometry->Surrealdb_Geometry.matches(pointGeometry),
      Surrealdb_Geometry.isInstance(pointGeometry->toUnknown),
      pointGeometry->toUnknown->Surrealdb_Geometry.fromUnknown->Option.isSome,
      line->Surrealdb_GeometryLine.line->Array.length,
      line->Surrealdb_GeometryLine.coordinates->Array.length,
      line->Surrealdb_GeometryLine.toJSON->jsonText,
      line->Surrealdb_GeometryLine.clone->Surrealdb_GeometryLine.matches(line->Surrealdb_GeometryLine.asGeometry),
      polygon->Surrealdb_GeometryPolygon.polygon->Array.length,
      polygon->Surrealdb_GeometryPolygon.coordinates->Array.length,
      polygon->Surrealdb_GeometryPolygon.toJSON->jsonText,
      multiPoint->Surrealdb_GeometryMultiPoint.points->Array.length,
      multiPoint->Surrealdb_GeometryMultiPoint.coordinates->Array.length,
      multiPoint->Surrealdb_GeometryMultiPoint.toJSON->jsonText,
      multiLine->Surrealdb_GeometryMultiLine.lines->Array.length,
      multiLine->Surrealdb_GeometryMultiLine.coordinates->Array.length,
      multiLine->Surrealdb_GeometryMultiLine.toJSON->jsonText,
      multiPolygon->Surrealdb_GeometryMultiPolygon.polygons->Array.length,
      multiPolygon->Surrealdb_GeometryMultiPolygon.coordinates->Array.length,
      multiPolygon->Surrealdb_GeometryMultiPolygon.toJSON->jsonText,
      collection->Surrealdb_GeometryCollection.collection->Array.length,
      collection->Surrealdb_GeometryCollection.geometries->Array.length,
      collection->Surrealdb_GeometryCollection.toJSON->jsonText,
      [
        Surrealdb_GeometryLine.isInstance(line->toUnknown),
        line->toUnknown->Surrealdb_GeometryLine.fromUnknown->Option.isSome,
        Surrealdb_GeometryPolygon.isInstance(polygon->toUnknown),
        polygon->toUnknown->Surrealdb_GeometryPolygon.fromUnknown->Option.isSome,
        Surrealdb_GeometryMultiPoint.isInstance(multiPoint->toUnknown),
        multiPoint->toUnknown->Surrealdb_GeometryMultiPoint.fromUnknown->Option.isSome,
        Surrealdb_GeometryMultiLine.isInstance(multiLine->toUnknown),
        multiLine->toUnknown->Surrealdb_GeometryMultiLine.fromUnknown->Option.isSome,
        Surrealdb_GeometryMultiPolygon.isInstance(multiPolygon->toUnknown),
        multiPolygon->toUnknown->Surrealdb_GeometryMultiPolygon.fromUnknown->Option.isSome,
        Surrealdb_GeometryCollection.isInstance(collection->toUnknown),
        collection->toUnknown->Surrealdb_GeometryCollection.fromUnknown->Option.isSome,
      ],
      [
        None->toUnknown->Surrealdb_BoundValue.fromUnknown,
        Nullable.null->nullableToUnknown->Surrealdb_BoundValue.fromUnknown,
        true->toUnknown->Surrealdb_BoundValue.fromUnknown,
        7->intToUnknown->Surrealdb_BoundValue.fromUnknown,
        7.5->floatToUnknown->Surrealdb_BoundValue.fromUnknown,
        "alpha"->stringToUnknown->Surrealdb_BoundValue.fromUnknown,
        bigintValue->toUnknown->Surrealdb_BoundValue.fromUnknown,
        symbolForUnknown("demo")->Surrealdb_BoundValue.fromUnknown,
        (() => ())->toUnknown->Surrealdb_BoundValue.fromUnknown,
        boundArray->toUnknown->Surrealdb_BoundValue.fromUnknown,
        boundObject->dictToUnknown->Surrealdb_BoundValue.fromUnknown,
        Surrealdb_Table.make("widgets")->toUnknown->Surrealdb_BoundValue.fromUnknown,
      ]
      ->Array.map(value => (value->Surrealdb_BoundValue.toText, value->Surrealdb_BoundValue.toJSON->jsonText)),
    )
    ->Expect.expect
    ->Expect.toEqual((
      [1.0, 2.0],
      [1.0, 2.0],
      "{\"type\":\"Point\",\"coordinates\":[1,2]}",
      true,
      true,
      true,
      true,
      "{\"type\":\"Point\",\"coordinates\":[1,2]}",
      true,
      true,
      true,
      true,
      3,
      3,
      "{\"type\":\"LineString\",\"coordinates\":[[1,2],[3,4],[1,2]]}",
      true,
      1,
      1,
      "{\"type\":\"Polygon\",\"coordinates\":[[[1,2],[3,4],[1,2]]]}",
      2,
      2,
      "{\"type\":\"MultiPoint\",\"coordinates\":[[1,2],[3,4]]}",
      1,
      1,
      "{\"type\":\"MultiLineString\",\"coordinates\":[[[1,2],[3,4],[1,2]]]}",
      1,
      1,
      "{\"type\":\"MultiPolygon\",\"coordinates\":[[[[1,2],[3,4],[1,2]]]]}",
      3,
      3,
      "{\"type\":\"GeometryCollection\",\"geometries\":[{\"type\":\"Point\",\"coordinates\":[1,2]},{\"type\":\"LineString\",\"coordinates\":[[1,2],[3,4],[1,2]]},{\"type\":\"Polygon\",\"coordinates\":[[[1,2],[3,4],[1,2]]]}]}",
      [true, true, true, true, true, true, true, true, true, true, true, true],
      [
        ("", "{\"boundValueType\":\"undefined\"}"),
        ("null", "null"),
        ("true", "true"),
        ("7", "7"),
        ("7.5", "7.5"),
        ("alpha", "\"alpha\""),
        ("9n", "{\"boundValueType\":\"bigint\",\"value\":\"9\"}"),
        ("<symbol>", "{\"boundValueType\":\"symbol\"}"),
        ("<function>", "{\"boundValueType\":\"function\"}"),
        ("1, two", "[1,\"two\"]"),
        ("count: 3; label: x", "{\"count\":3,\"label\":\"x\"}"),
        ("widgets", "\"widgets\""),
      ],
    ))
  })
})
