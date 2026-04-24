module Support = SurrealdbSessionTestSupport

let closeIgnore = Support.closeIgnore
let removeTableIgnore = Support.removeTableIgnore
let objectIntFieldText = Support.objectIntFieldText
let connectServerDatabase = Support.connectServerDatabase
let responseStatus = Support.responseStatus
let toUnknown = SurrealdbTestCasts.toUnknown

Vitest.describe("SurrealDB query runtime surface", () => {
  Vitest.testAsync("transactions expose shared queryable behavior across commit and cancel", async t => {
    let db = Surrealdb_Surreal.make()
    let tableName = "tx_items"
    let committedId = Surrealdb_RecordId.make(tableName, "from_tx")
    let cancelledId = Surrealdb_RecordId.make(tableName, "cancelled")
    try {
      await connectServerDatabase(db)

      await removeTableIgnore(db, tableName)
      ignore(await db->Surrealdb_Query.runText(`DEFINE TABLE ${tableName} SCHEMALESS;`))

      let committedTx = await db->Surrealdb_Surreal.beginTransaction
      let committedQueryable = committedTx->Surrealdb_Transaction.asQueryable
      ignore(
        await committedQueryable
        ->Surrealdb_Create.recordOn(tableName, "from_tx")
        ->Surrealdb_Create.content(Dict.fromArray([("value", Surrealdb_JsValue.int(1))]))
        ->Surrealdb_Create.resolve
      )
      let insideCommitted =
        await committedQueryable
        ->Surrealdb_Select.fromRecordIdOn(committedId)
        ->Surrealdb_Select.resolve
      let outsideBeforeCommit =
        await db
        ->Surrealdb_Surreal.asQueryable
        ->Surrealdb_Select.fromRecordIdOn(committedId)
        ->Surrealdb_Select.resolve
      await committedTx->Surrealdb_Transaction.commit
      let outsideAfterCommit =
        await db
        ->Surrealdb_Surreal.asQueryable
        ->Surrealdb_Select.fromRecordIdOn(committedId)
        ->Surrealdb_Select.resolve

      let cancelledTx = await db->Surrealdb_Surreal.beginTransaction
      let cancelledQueryable = cancelledTx->Surrealdb_Transaction.asQueryable
      ignore(
        await cancelledQueryable
        ->Surrealdb_Create.fromRecordIdOn(cancelledId)
        ->Surrealdb_Create.content(Dict.fromArray([("value", Surrealdb_JsValue.int(2))]))
        ->Surrealdb_Create.resolve
      )
      let insideCancelled =
        await cancelledQueryable
        ->Surrealdb_Select.fromRecordIdOn(cancelledId)
        ->Surrealdb_Select.resolve
      let outsideBeforeCancel =
        await db
        ->Surrealdb_Surreal.asQueryable
        ->Surrealdb_Select.fromRecordIdOn(cancelledId)
        ->Surrealdb_Select.resolve
      await cancelledTx->Surrealdb_Transaction.cancel
      let outsideAfterCancel =
        await db
        ->Surrealdb_Surreal.asQueryable
        ->Surrealdb_Select.fromRecordIdOn(cancelledId)
        ->Surrealdb_Select.resolve

      t->Vitest.expect((
        insideCommitted->objectIntFieldText("value"),
        outsideBeforeCommit->objectIntFieldText("value"),
        outsideAfterCommit->objectIntFieldText("value"),
        insideCancelled->objectIntFieldText("value"),
        outsideBeforeCancel->objectIntFieldText("value"),
        outsideAfterCancel->objectIntFieldText("value"),
      ))->Vitest.Expect.toEqual((
        Some("1"),
        None,
        Some("1"),
        Some("2"),
        None,
        None,
      ))

      await removeTableIgnore(db, tableName)
      await closeIgnore(db)
    } catch {
    | error =>
      await removeTableIgnore(db, tableName)
      await closeIgnore(db)
      throw(error)
    }
  })

  Vitest.testAsync("query and run allow omitted optional arguments on the installed public SDK surface", async t => {
    let db = Surrealdb_Surreal.make()
    try {
      await connectServerDatabase(db)

      let query = db->Surrealdb_Query.text("RETURN 1;", ())
      let awaited = await db->Surrealdb_Query.text("RETURN 1; RETURN 2;", ())->Surrealdb_Query.resolve
      let responses = await query->Surrealdb_Query.responses

      t->Vitest.expect((
        query->Surrealdb_Query.inner->Surrealdb_BoundQuery.query,
        query->Surrealdb_Query.inner->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length,
        awaited->Array.map(Surrealdb_Value.toText),
        responses->Array.length,
        responses->Array.get(0)->Option.map(Surrealdb_QueryResponse.success),
        responses->Array.get(0)->Option.flatMap(Surrealdb_QueryResponse.type_),
        responses->Array.get(0)
        ->Option.flatMap(Surrealdb_QueryResponse.result)
        ->Option.map(Surrealdb_Value.toText),
      ))->Vitest.Expect.toEqual((
        "RETURN 1;",
        0,
        ["1", "2"],
        1,
        Some(true),
        Some(Surrealdb_QueryType.Other),
        Some("1"),
      ))

      await closeIgnore(db)
    } catch {
    | error =>
      await closeIgnore(db)
      throw(error)
    }
  })

  Vitest.testAsync("streamed error frames expose throw() on the installed public SDK surface", async t => {
    let db = Surrealdb_Surreal.make()
    try {
      await connectServerDatabase(db)

      let frames =
        await db
        ->Surrealdb_Query.text("RETURN 1; THROW 'boom'", ())
        ->Surrealdb_Query.stream
        ->Surrealdb_AsyncIterable.collect

      let errorFrame =
        frames
        ->Array.get(2)
        ->Option.flatMap(Surrealdb_QueryFrame.asError)
        ->Option.getOrThrow

      let thrown =
        try {
          errorFrame->Surrealdb_QueryFrame.throw_
        } catch {
        | JsExn(jsError) =>
          switch jsError->toUnknown->Surrealdb_ServerError.fromUnknown {
          | Some(serverError) => serverError->Surrealdb_ServerError.asSurrealError->Surrealdb_SurrealError.message
          | None => jsError->JsExn.message->Option.getOr("unexpected js error")
          }
        | _ => "unexpected non-js error"
        }

      t->Vitest.expect((
        frames->Array.length,
        frames->Array.get(0)->Option.map(frame => (frame->Surrealdb_QueryFrame.isValue_, frame->Surrealdb_QueryFrame.query)),
        frames->Array.get(1)->Option.map(frame => (frame->Surrealdb_QueryFrame.isDone_, frame->Surrealdb_QueryFrame.query)),
        frames->Array.get(2)->Option.map(frame => (frame->Surrealdb_QueryFrame.isError_, frame->Surrealdb_QueryFrame.query)),
        errorFrame->Surrealdb_QueryFrame.errorValue->Surrealdb_ServerError.kind,
        thrown,
      ))->Vitest.Expect.toEqual((
        3,
        Some((true, 0)),
        Some((true, 0)),
        Some((true, 1)),
        Surrealdb_ErrorKind.thrown,
        "An error occurred: boom",
      ))

      await closeIgnore(db)
    } catch {
    | error =>
      await closeIgnore(db)
      throw(error)
    }
  })

  Vitest.testAsync("export allows omitted options on the installed public SDK surface", async t => {
    let db = Surrealdb_Surreal.make()
    try {
      await connectServerDatabase(db)

      let exportSql = await db->Surrealdb_Export.exportSqlDefault->Surrealdb_Export.awaitSql
      let rawResponse =
        await db
        ->Surrealdb_Export.exportSqlDefault
        ->Surrealdb_Export.rawSql
        ->Surrealdb_Export.awaitSql
      t->Vitest.expect(exportSql != "")->Vitest.Expect.toBe(true)
      t->Vitest.expect(rawResponse->responseStatus)->Vitest.Expect.toBe(200)

      await closeIgnore(db)
    } catch {
    | error =>
      await closeIgnore(db)
      throw(error)
    }
  })

  Vitest.testAsync("exportModel surfaces the installed missing-model http error", async t => {
    let db = Surrealdb_Surreal.make()
    try {
      await connectServerDatabase(db)

      let outcome =
        try {
          ignore(await db->Surrealdb_Export.exportModel("missing_model", "1")->Surrealdb_Export.awaitModel)
          "no error"
        } catch {
        | JsExn(jsError) =>
          switch jsError->toUnknown->Surrealdb_ClientError.asHttpConnection {
          | Some(error) => `${error->Surrealdb_ClientError.httpConnectionStatus->Int.toString}:${error->Surrealdb_ClientError.httpConnectionStatusText}`
          | None => jsError->JsExn.message->Option.getOr("unexpected js error")
          }
        | _ => "unexpected non-js error"
        }

      t->Vitest.expect(outcome)->Vitest.Expect.toBe("404:Not Found")

      await closeIgnore(db)
    } catch {
    | error =>
      await closeIgnore(db)
      throw(error)
    }
  })

  Vitest.testAsync("import accepts blob and readable-stream inputs through the installed public SDK surface", async t => {
    let db = Surrealdb_Surreal.make()
    let tableName = "import_probe"
    let blobId = Surrealdb_RecordId.make(tableName, "blob")
    let streamId = Surrealdb_RecordId.make(tableName, "stream")
    try {
      await connectServerDatabase(db)

      await removeTableIgnore(db, tableName)
      let blob =
        [Webapi.Blob.stringToBlobPart(
          `OPTION IMPORT; DEFINE TABLE ${tableName} SCHEMALESS; CREATE ${tableName}:blob CONTENT { value: 1 };`,
        )]
        ->Webapi.Blob.make
      await db->Surrealdb_Surreal.importBlob(blob)
      let afterBlob =
        await db
        ->Surrealdb_Surreal.asQueryable
        ->Surrealdb_Select.fromRecordIdOn(blobId)
        ->Surrealdb_Select.resolve

      let stream =
        [Webapi.Blob.stringToBlobPart(`OPTION IMPORT; CREATE ${tableName}:stream CONTENT { value: 2 };`)]
        ->Webapi.Blob.make
        ->Webapi.Blob.stream
      await db->Surrealdb_Surreal.importStream(stream)
      let afterStream =
        await db
        ->Surrealdb_Surreal.asQueryable
        ->Surrealdb_Select.fromRecordIdOn(streamId)
        ->Surrealdb_Select.resolve

      t->Vitest.expect((
        afterBlob->objectIntFieldText("value"),
        afterStream->objectIntFieldText("value"),
      ))->Vitest.Expect.toEqual((Some("1"), Some("2")))

      await removeTableIgnore(db, tableName)
      await closeIgnore(db)
    } catch {
    | error =>
      await removeTableIgnore(db, tableName)
      await closeIgnore(db)
      throw(error)
    }
  })

})
