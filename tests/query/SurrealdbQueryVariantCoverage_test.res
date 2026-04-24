module SessionSupport = SurrealdbSessionTestSupport
module CoverageSupport = SurrealdbCoverageTestSupport

let closeIgnore = SessionSupport.closeIgnore
let connectServerDatabase = SessionSupport.connectServerDatabase
let removeTableIgnore = SessionSupport.removeTableIgnore
let makeDisconnectedDb = CoverageSupport.makeDisconnectedDb

let normalizeBindSlots = query =>
  query
  ->String.split(" ")
  ->Array.map(token =>
      if token->String.startsWith("$bind__") {
        "$bind__"
      } else {
        token
      }
    )
  ->Belt.Array.joinWith(" ", token => token)

let rec valueObjectFieldText = (value, fieldName) =>
  switch value {
  | Surrealdb_Value.Object(entries) => entries->Dict.get(fieldName)->Option.map(Surrealdb_Value.toText)
  | Surrealdb_Value.Array(values) => values->Array.get(0)->Option.flatMap(value => valueObjectFieldText(value, fieldName))
  | _ => None
  }

let jsonScalarText = value =>
  switch value->JSON.Decode.string {
  | Some(text) => Some(text)
  | None => value->JSON.stringifyAny
  }

let rec jsonObjectFieldText = (value, fieldName) =>
  switch value->JSON.Decode.object {
  | Some(entries) =>
    switch entries->Dict.get(fieldName) {
    | Some(fieldValue) => fieldValue->jsonScalarText
    | None => None
    }
  | None =>
    switch value->JSON.Decode.array {
    | Some(values) => values->Array.get(0)->Option.flatMap(value => jsonObjectFieldText(value, fieldName))
    | None => None
    }
  }

let jsonFrameFieldText = (~frame, ~fieldName) =>
  frame
  ->Surrealdb_JsonFrame.asValue
  ->Option.flatMap(valueFrame => valueFrame->Surrealdb_JsonFrame.value->jsonObjectFieldText(fieldName))

let jsonFrameValueText = frame =>
  frame
  ->Surrealdb_JsonFrame.asValue
  ->Option.flatMap(valueFrame => valueFrame->Surrealdb_JsonFrame.value->JSON.stringifyAny)

let jsonFrameDoneType = frame =>
  frame->Surrealdb_JsonFrame.asDone->Option.map(Surrealdb_JsonFrame.doneType)

let valueFrameFieldText = (~frame, ~fieldName) =>
  frame
  ->Surrealdb_QueryFrame.asValue
  ->Option.flatMap(valueFrame => valueFrame->Surrealdb_QueryFrame.value->valueObjectFieldText(fieldName))

let valueFrameDoneType = frame =>
  frame->Surrealdb_QueryFrame.asDone->Option.map(Surrealdb_QueryFrame.doneType)

let makeData = (~label, ~count) =>
  Dict.fromArray([
    ("label", Surrealdb_JsValue.string(label)),
    ("count", Surrealdb_JsValue.int(count)),
  ])

Vitest.describe("SurrealDB query variant coverage", () => {
  Vitest.test("remaining queryable and db entrypoints compile through the public surface", t => {
    let db = makeDisconnectedDb()
    let queryable = db->Surrealdb_Surreal.asQueryable
    let table = Surrealdb_Table.make("widgets")
    let recordId = Surrealdb_RecordId.make("widgets", "alpha")
    let otherRecordId = Surrealdb_RecordId.make("widgets", "beta")
    let edgeTable = Surrealdb_Table.make("links")
    let range =
      Surrealdb_RecordIdRange.make(
        ~table="widgets",
        ~begin=Surrealdb_RangeBound.included(Surrealdb_RangeBound.String("a")),
        ~end=Surrealdb_RangeBound.excluded(Surrealdb_RangeBound.String("z")),
        (),
      )
    let data = Surrealdb_JsValue.object(makeData(~label="alpha", ~count=3))

    let deleteRangeCompiled = queryable->Surrealdb_Delete.rangeOn(range)->Surrealdb_Delete.compile
    let deleteRecordCompiled = db->Surrealdb_Delete.fromRecordId(recordId)->Surrealdb_Delete.compile
    let deleteRecordOnCompiled = queryable->Surrealdb_Delete.fromRecordIdOn(recordId)->Surrealdb_Delete.compile
    let deleteTableOnCompiled = queryable->Surrealdb_Delete.fromTableOn(table)->Surrealdb_Delete.compile

    let updateRangeCompiled = queryable->Surrealdb_Update.rangeOn(range)->Surrealdb_Update.compile
    let updateRecordCompiled = db->Surrealdb_Update.fromRecordId(recordId)->Surrealdb_Update.compile
    let updateRecordOnCompiled = queryable->Surrealdb_Update.fromRecordIdOn(recordId)->Surrealdb_Update.compile
    let updateTableOnCompiled = queryable->Surrealdb_Update.fromTableOn(table)->Surrealdb_Update.compile

    let insertDataOnCompiled = queryable->Surrealdb_Insert.dataOn(data)->Surrealdb_Insert.compile
    let insertFromDataOnCompiled = queryable->Surrealdb_Insert.fromDataOn(data)->Surrealdb_Insert.compile

    let upsertRangeCompiled = queryable->Surrealdb_Upsert.rangeOn(range)->Surrealdb_Upsert.compile
    let upsertTableOnCompiled = queryable->Surrealdb_Upsert.fromTableOn(table)->Surrealdb_Upsert.compile
    let upsertRangeOnCompiled = queryable->Surrealdb_Upsert.fromRangeOn(range)->Surrealdb_Upsert.compile

    let relateNoDataCompiled =
      queryable
      ->Surrealdb_Relate.recordNoDataOn(recordId, edgeTable, otherRecordId)
      ->Surrealdb_Relate.compile
    let relateArrayNoDataCompiled =
      queryable
      ->Surrealdb_Relate.recordArraysNoDataOn([recordId], edgeTable, [otherRecordId])
      ->Surrealdb_Relate.compile
    let relateArrayWithDataCompiled =
      queryable
      ->Surrealdb_Relate.recordArraysWithDataOn([recordId], edgeTable, [otherRecordId], makeData(~label="edge", ~count=1))
      ->Surrealdb_Relate.compile

    let runFunctionCompiled =
      db->Surrealdb_Run.function_("time::now", ())->Surrealdb_Run.compile
    let runFunctionOnCompiled =
      queryable
      ->Surrealdb_Run.functionOn("string::len", [Surrealdb_JsValue.string("alpha")])
      ->Surrealdb_Run.compile
    let runFunctionNoArgsOnCompiled =
      queryable->Surrealdb_Run.functionNoArgsOn("time::now")->Surrealdb_Run.compile
    let runVersionedNoArgsOnCompiled =
      queryable
      ->Surrealdb_Run.versionedFunctionNoArgsOn("time::now", "2.0.0")
      ->Surrealdb_Run.compile

    t->Vitest.expect([
      (deleteRangeCompiled->Surrealdb_BoundQuery.query->normalizeBindSlots, deleteRangeCompiled->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length),
      (deleteRecordCompiled->Surrealdb_BoundQuery.query->normalizeBindSlots, deleteRecordCompiled->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length),
      (deleteRecordOnCompiled->Surrealdb_BoundQuery.query->normalizeBindSlots, deleteRecordOnCompiled->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length),
      (deleteTableOnCompiled->Surrealdb_BoundQuery.query->normalizeBindSlots, deleteTableOnCompiled->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length),
      (updateRangeCompiled->Surrealdb_BoundQuery.query->normalizeBindSlots, updateRangeCompiled->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length),
      (updateRecordCompiled->Surrealdb_BoundQuery.query->normalizeBindSlots, updateRecordCompiled->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length),
      (updateRecordOnCompiled->Surrealdb_BoundQuery.query->normalizeBindSlots, updateRecordOnCompiled->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length),
      (updateTableOnCompiled->Surrealdb_BoundQuery.query->normalizeBindSlots, updateTableOnCompiled->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length),
      (insertDataOnCompiled->Surrealdb_BoundQuery.query->normalizeBindSlots, insertDataOnCompiled->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length),
      (insertFromDataOnCompiled->Surrealdb_BoundQuery.query->normalizeBindSlots, insertFromDataOnCompiled->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length),
      (upsertRangeCompiled->Surrealdb_BoundQuery.query->normalizeBindSlots, upsertRangeCompiled->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length),
      (upsertTableOnCompiled->Surrealdb_BoundQuery.query->normalizeBindSlots, upsertTableOnCompiled->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length),
      (upsertRangeOnCompiled->Surrealdb_BoundQuery.query->normalizeBindSlots, upsertRangeOnCompiled->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length),
      (relateNoDataCompiled->Surrealdb_BoundQuery.query->normalizeBindSlots, relateNoDataCompiled->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length),
      (relateArrayNoDataCompiled->Surrealdb_BoundQuery.query->normalizeBindSlots, relateArrayNoDataCompiled->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length),
      (relateArrayWithDataCompiled->Surrealdb_BoundQuery.query->normalizeBindSlots, relateArrayWithDataCompiled->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length),
      (runFunctionCompiled->Surrealdb_BoundQuery.query->normalizeBindSlots, runFunctionCompiled->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length),
      (runFunctionNoArgsOnCompiled->Surrealdb_BoundQuery.query->normalizeBindSlots, runFunctionNoArgsOnCompiled->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length),
      (runVersionedNoArgsOnCompiled->Surrealdb_BoundQuery.query->normalizeBindSlots, runVersionedNoArgsOnCompiled->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length),
    ])->Vitest.Expect.toEqual([
        ("DELETE $bind__ RETURN BEFORE", 1),
        ("DELETE ONLY $bind__ RETURN BEFORE", 1),
        ("DELETE ONLY $bind__ RETURN BEFORE", 1),
        ("DELETE $bind__ RETURN BEFORE", 1),
        ("UPDATE $bind__", 1),
        ("UPDATE ONLY $bind__", 1),
        ("UPDATE ONLY $bind__", 1),
        ("UPDATE $bind__", 1),
        ("INSERT $bind__", 1),
        ("INSERT $bind__", 1),
        ("UPSERT $bind__", 1),
        ("UPSERT $bind__", 1),
        ("UPSERT $bind__", 1),
        ("RELATE  ONLY $bind__", 3),
        ("RELATE  $bind__", 3),
        ("RELATE  $bind__ CONTENT $bind__", 4),
        ("time::now()", 0),
        ("time::now()", 0),
        ("time::now<2.0.0>()", 0),
      ])
    t->Vitest.expect((
      runFunctionOnCompiled->Surrealdb_BoundQuery.query->String.startsWith("string::len($bind__"),
      runFunctionOnCompiled->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length,
    ))->Vitest.Expect.toEqual((true, 1))
  })

  Vitest.testAsync("mutation and run resolution variants execute through the live server path", async t => {
    let db = Surrealdb_Surreal.make()
    let tableName = "query_variant_coverage"
    let edgeTableName = "query_variant_edge_coverage"
    let table = Surrealdb_Table.make(tableName)
    let edgeTable = Surrealdb_Table.make(edgeTableName)
    let queryable = db->Surrealdb_Surreal.asQueryable
    let makeId = slug => Surrealdb_RecordId.make(tableName, slug)
    let seed = (slug, label) =>
      db
      ->Surrealdb_Create.fromRecordId(makeId(slug))
      ->Surrealdb_Create.content(makeData(~label, ~count=3))
      ->Surrealdb_Create.resolve
    try {
      await connectServerDatabase(db)
      await removeTableIgnore(db, tableName)
      await removeTableIgnore(db, edgeTableName)
      ignore(await db->Surrealdb_Query.runText(`DEFINE TABLE ${tableName} SCHEMALESS;`))
      ignore(await db->Surrealdb_Query.runText(`DEFINE TABLE ${edgeTableName} TYPE RELATION SCHEMALESS;`))

      ignore(await seed("delete-json", "delete-json"))
      let deleteResolvedJson =
        await db->Surrealdb_Delete.fromRecordId(makeId("delete-json"))->Surrealdb_Delete.json->Surrealdb_Delete.resolveJson
      ignore(await seed("delete-then", "delete-then"))
      let deleteThenResolved =
        await db
        ->Surrealdb_Delete.fromRecordId(makeId("delete-then"))
        ->Surrealdb_Delete.thenResolve(value => value)
      ignore(await seed("delete-then-json", "delete-then-json"))
      let deleteThenResolvedJson =
        await db
        ->Surrealdb_Delete.fromRecordId(makeId("delete-then-json"))
        ->Surrealdb_Delete.json
        ->Surrealdb_Delete.thenResolveJson(value => value)
      ignore(await seed("delete-stream", "delete-stream"))
      let deleteStream =
        await db
        ->Surrealdb_Delete.fromRecordId(makeId("delete-stream"))
        ->Surrealdb_Delete.stream
        ->Surrealdb_AsyncIterable.collect
      ignore(await seed("delete-stream-json", "delete-stream-json"))
      let deleteStreamJson =
        await db
        ->Surrealdb_Delete.fromRecordId(makeId("delete-stream-json"))
        ->Surrealdb_Delete.json
        ->Surrealdb_Delete.streamJson
        ->Surrealdb_AsyncIterable.collect

      ignore(await seed("update-json", "update-old"))
      let updateResolvedJson =
        await db
        ->Surrealdb_Update.fromRecordId(makeId("update-json"))
        ->Surrealdb_Update.content(makeData(~label="update-json", ~count=4))
        ->Surrealdb_Update.json
        ->Surrealdb_Update.resolveJson
      ignore(await seed("update-then", "update-old"))
      let updateThenResolved =
        await db
        ->Surrealdb_Update.fromRecordId(makeId("update-then"))
        ->Surrealdb_Update.content(makeData(~label="update-then", ~count=4))
        ->Surrealdb_Update.thenResolve(value => value)
      ignore(await seed("update-then-json", "update-old"))
      let updateThenResolvedJson =
        await db
        ->Surrealdb_Update.fromRecordId(makeId("update-then-json"))
        ->Surrealdb_Update.content(makeData(~label="update-then-json", ~count=4))
        ->Surrealdb_Update.json
        ->Surrealdb_Update.thenResolveJson(value => value)
      ignore(await seed("update-stream", "update-old"))
      let updateStream =
        await db
        ->Surrealdb_Update.fromRecordId(makeId("update-stream"))
        ->Surrealdb_Update.content(makeData(~label="update-stream", ~count=4))
        ->Surrealdb_Update.stream
        ->Surrealdb_AsyncIterable.collect
      ignore(await seed("update-stream-json", "update-old"))
      let updateStreamJson =
        await db
        ->Surrealdb_Update.fromRecordId(makeId("update-stream-json"))
        ->Surrealdb_Update.content(makeData(~label="update-stream-json", ~count=4))
        ->Surrealdb_Update.json
        ->Surrealdb_Update.streamJson
        ->Surrealdb_AsyncIterable.collect

      let insertResolved =
        await db
        ->Surrealdb_Insert.intoTable(table, Surrealdb_JsValue.object(makeData(~label="insert-resolve", ~count=5)))
        ->Surrealdb_Insert.resolve
      let insertResolvedJson =
        await db
        ->Surrealdb_Insert.intoTable(table, Surrealdb_JsValue.object(makeData(~label="insert-json", ~count=5)))
        ->Surrealdb_Insert.json
        ->Surrealdb_Insert.resolveJson
      let insertThenResolved =
        await db
        ->Surrealdb_Insert.intoTable(table, Surrealdb_JsValue.object(makeData(~label="insert-then", ~count=5)))
        ->Surrealdb_Insert.thenResolve(value => value)
      let insertThenResolvedJson =
        await db
        ->Surrealdb_Insert.intoTable(table, Surrealdb_JsValue.object(makeData(~label="insert-then-json", ~count=5)))
        ->Surrealdb_Insert.json
        ->Surrealdb_Insert.thenResolveJson(value => value)
      let insertStream =
        await db
        ->Surrealdb_Insert.intoTable(table, Surrealdb_JsValue.object(makeData(~label="insert-stream", ~count=5)))
        ->Surrealdb_Insert.stream
        ->Surrealdb_AsyncIterable.collect
      let insertStreamJson =
        await db
        ->Surrealdb_Insert.intoTable(table, Surrealdb_JsValue.object(makeData(~label="insert-stream-json", ~count=5)))
        ->Surrealdb_Insert.json
        ->Surrealdb_Insert.streamJson
        ->Surrealdb_AsyncIterable.collect

      let upsertResolvedJson =
        await db
        ->Surrealdb_Upsert.fromRecordId(makeId("upsert-json"))
        ->Surrealdb_Upsert.content(makeData(~label="upsert-json", ~count=6))
        ->Surrealdb_Upsert.json
        ->Surrealdb_Upsert.resolveJson
      let upsertThenResolved =
        await db
        ->Surrealdb_Upsert.fromRecordId(makeId("upsert-then"))
        ->Surrealdb_Upsert.content(makeData(~label="upsert-then", ~count=6))
        ->Surrealdb_Upsert.thenResolve(value => value)
      let upsertThenResolvedJson =
        await db
        ->Surrealdb_Upsert.fromRecordId(makeId("upsert-then-json"))
        ->Surrealdb_Upsert.content(makeData(~label="upsert-then-json", ~count=6))
        ->Surrealdb_Upsert.json
        ->Surrealdb_Upsert.thenResolveJson(value => value)
      let upsertStream =
        await db
        ->Surrealdb_Upsert.fromRecordId(makeId("upsert-stream"))
        ->Surrealdb_Upsert.content(makeData(~label="upsert-stream", ~count=6))
        ->Surrealdb_Upsert.stream
        ->Surrealdb_AsyncIterable.collect
      let upsertStreamJson =
        await db
        ->Surrealdb_Upsert.fromRecordId(makeId("upsert-stream-json"))
        ->Surrealdb_Upsert.content(makeData(~label="upsert-stream-json", ~count=6))
        ->Surrealdb_Upsert.json
        ->Surrealdb_Upsert.streamJson
        ->Surrealdb_AsyncIterable.collect

      ignore(await seed("alpha", "alpha"))
      ignore(await seed("beta", "beta"))
      let relateResolvedJson =
        await db
        ->Surrealdb_Relate.records(
            makeId("alpha"),
            edgeTable,
            makeId("beta"),
            ~data=makeData(~label="edge-json", ~count=1),
            (),
          )
        ->Surrealdb_Relate.json
        ->Surrealdb_Relate.resolveJson
      let relateThenResolved =
        await db
        ->Surrealdb_Relate.records(
            makeId("alpha"),
            edgeTable,
            makeId("beta"),
            ~data=makeData(~label="edge-then", ~count=1),
            (),
          )
        ->Surrealdb_Relate.thenResolve(value => value)
      let relateThenResolvedJson =
        await db
        ->Surrealdb_Relate.records(
            makeId("alpha"),
            edgeTable,
            makeId("beta"),
            ~data=makeData(~label="edge-then-json", ~count=1),
            (),
          )
        ->Surrealdb_Relate.json
        ->Surrealdb_Relate.thenResolveJson(value => value)
      let relateStreamJson =
        await db
        ->Surrealdb_Relate.records(
            makeId("alpha"),
            edgeTable,
            makeId("beta"),
            ~data=makeData(~label="edge-stream-json", ~count=1),
            (),
          )
        ->Surrealdb_Relate.json
        ->Surrealdb_Relate.streamJson
        ->Surrealdb_AsyncIterable.collect

      let runThenResolvedJson =
        await queryable
        ->Surrealdb_Run.callOn("string::len", ~args=[Surrealdb_JsValue.string("alpha")], ())
        ->Surrealdb_Run.json
        ->Surrealdb_Run.thenResolveJson(value => value)
      let runStreamJson =
        await queryable
        ->Surrealdb_Run.callOn("string::len", ~args=[Surrealdb_JsValue.string("alpha")], ())
        ->Surrealdb_Run.json
        ->Surrealdb_Run.streamJson
        ->Surrealdb_AsyncIterable.collect

      t->Vitest.expect((
        deleteResolvedJson->jsonObjectFieldText("label"),
        deleteThenResolved->valueObjectFieldText("label"),
        deleteThenResolvedJson->jsonObjectFieldText("label"),
        deleteStream->Array.length,
        deleteStream->Array.get(0)->Option.flatMap(frame => valueFrameFieldText(~frame, ~fieldName="label")),
        deleteStream->Array.get(1)->Option.flatMap(valueFrameDoneType),
        deleteStreamJson->Array.length,
        deleteStreamJson->Array.get(0)->Option.flatMap(frame => jsonFrameFieldText(~frame, ~fieldName="label")),
        deleteStreamJson->Array.get(1)->Option.flatMap(jsonFrameDoneType),
        updateResolvedJson->jsonObjectFieldText("label"),
        updateThenResolved->valueObjectFieldText("label"),
        updateThenResolvedJson->jsonObjectFieldText("label"),
        updateStream->Array.length,
        updateStream->Array.get(0)->Option.flatMap(frame => valueFrameFieldText(~frame, ~fieldName="label")),
        updateStreamJson->Array.length,
        updateStreamJson->Array.get(0)->Option.flatMap(frame => jsonFrameFieldText(~frame, ~fieldName="label")),
        insertResolved->valueObjectFieldText("label"),
        insertResolvedJson->jsonObjectFieldText("label"),
        insertThenResolved->valueObjectFieldText("label"),
        insertThenResolvedJson->jsonObjectFieldText("label"),
        insertStream->Array.length,
        insertStream->Array.get(0)->Option.flatMap(frame => valueFrameFieldText(~frame, ~fieldName="label")),
        insertStreamJson->Array.length,
        insertStreamJson->Array.get(0)->Option.flatMap(frame => jsonFrameFieldText(~frame, ~fieldName="label")),
        upsertResolvedJson->jsonObjectFieldText("label"),
        upsertThenResolved->valueObjectFieldText("label"),
        upsertThenResolvedJson->jsonObjectFieldText("label"),
        upsertStream->Array.length,
        upsertStream->Array.get(0)->Option.flatMap(frame => valueFrameFieldText(~frame, ~fieldName="label")),
        upsertStreamJson->Array.length,
        upsertStreamJson->Array.get(0)->Option.flatMap(frame => jsonFrameFieldText(~frame, ~fieldName="label")),
        relateResolvedJson->jsonObjectFieldText("label"),
        relateThenResolved->valueObjectFieldText("label"),
        relateThenResolvedJson->jsonObjectFieldText("label"),
        relateStreamJson->Array.length,
        relateStreamJson->Array.get(0)->Option.flatMap(frame => jsonFrameFieldText(~frame, ~fieldName="label")),
        relateStreamJson->Array.get(1)->Option.flatMap(jsonFrameDoneType),
        runThenResolvedJson->JSON.stringifyAny,
        runStreamJson->Array.length,
        runStreamJson->Array.get(0)->Option.flatMap(jsonFrameValueText),
        runStreamJson->Array.get(1)->Option.flatMap(jsonFrameDoneType),
      ))->Vitest.Expect.toEqual((
        Some("delete-json"),
        Some("delete-then"),
        Some("delete-then-json"),
        2,
        Some("delete-stream"),
        Some(Surrealdb_QueryType.Other),
        2,
        Some("delete-stream-json"),
        Some(Surrealdb_QueryType.Other),
        Some("update-json"),
        Some("update-then"),
        Some("update-then-json"),
        2,
        Some("update-stream"),
        2,
        Some("update-stream-json"),
        Some("insert-resolve"),
        Some("insert-json"),
        Some("insert-then"),
        Some("insert-then-json"),
        2,
        Some("insert-stream"),
        2,
        Some("insert-stream-json"),
        Some("upsert-json"),
        Some("upsert-then"),
        Some("upsert-then-json"),
        2,
        Some("upsert-stream"),
        2,
        Some("upsert-stream-json"),
        Some("edge-json"),
        Some("edge-then"),
        Some("edge-then-json"),
        2,
        Some("edge-stream-json"),
        Some(Surrealdb_QueryType.Other),
        Some("5"),
        2,
        Some("5"),
        Some(Surrealdb_QueryType.Other),
      ))

      await removeTableIgnore(db, tableName)
      await removeTableIgnore(db, edgeTableName)
      await closeIgnore(db)
    } catch {
    | error =>
      await removeTableIgnore(db, tableName)
      await removeTableIgnore(db, edgeTableName)
      await closeIgnore(db)
      throw(error)
    }
  })
})
