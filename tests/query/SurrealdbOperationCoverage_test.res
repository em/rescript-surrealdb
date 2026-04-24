module SessionSupport = SurrealdbSessionTestSupport
module CoverageSupport = SurrealdbCoverageTestSupport

let closeIgnore = SessionSupport.closeIgnore
let connectServerDatabase = SessionSupport.connectServerDatabase
let removeTableIgnore = SessionSupport.removeTableIgnore
let namespaceDatabaseSelection = SessionSupport.namespaceDatabaseSelection
let responseStatus = SessionSupport.responseStatus
let hasField = CoverageSupport.hasField
let dictFieldText = CoverageSupport.dictFieldText

let objectFieldText = (value, fieldName) =>
  switch value {
  | Surrealdb_Value.Object(entries) => entries->Dict.get(fieldName)->Option.map(Surrealdb_Value.toText)
  | _ => None
  }

let firstObjectFieldText = (value, fieldName) =>
  switch value {
  | Surrealdb_Value.Object(_) => objectFieldText(value, fieldName)
  | Surrealdb_Value.Array(values) => values->Array.get(0)->Option.flatMap(value => objectFieldText(value, fieldName))
  | _ => None
  }

let arrayObjectFieldTexts = (value, fieldName) =>
  switch value {
  | Surrealdb_Value.Array(values) => values->Array.map(value => objectFieldText(value, fieldName))
  | _ => [None]
  }

let frameObjectFieldText = (~frame, ~fieldName) =>
  frame
  ->Surrealdb_QueryFrame.asValue
  ->Option.flatMap(valueFrame => objectFieldText(valueFrame->Surrealdb_QueryFrame.value, fieldName))

let frameDoneType = frame =>
  frame->Surrealdb_QueryFrame.asDone->Option.map(Surrealdb_QueryFrame.doneType)

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

Vitest.describe("SurrealDB query operation coverage", () => {
  Vitest.test("statement builders and export options stay explicit on the public surface", t => {
    let sqlOptionsAll =
      Surrealdb_Export.sqlOptions(
        ~users=true,
        ~tables=Surrealdb_Export.AllTables(true),
        ~records=false,
        (),
      )
    let sqlOptionsFiltered =
      Surrealdb_Export.sqlOptions(
        ~tables=Surrealdb_Export.OnlyTables(["widgets", "edges"]),
        ~v3=true,
        (),
      )
    let databaseInfo = Surrealdb_Query.databaseInfoStatement()
    let tableInfo = Surrealdb_Query.tableInfoStatement("widgets")
    let countAll = Surrealdb_Query.countAllStatement("widgets")
    let tableStructure = Surrealdb_Query.tableStructureStatement("widgets")
    let dbStructure = Surrealdb_Query.dbStructureStatement()

    t->Vitest.expect((
      sqlOptionsAll->hasField("users"),
      sqlOptionsAll->dictFieldText("tables"),
      sqlOptionsFiltered->dictFieldText("tables"),
      sqlOptionsFiltered->hasField("v3"),
      databaseInfo->Surrealdb_BoundQuery.query,
      tableInfo->Surrealdb_BoundQuery.query,
      countAll->Surrealdb_BoundQuery.query,
      tableStructure->Surrealdb_BoundQuery.query,
      dbStructure->Surrealdb_BoundQuery.query,
    ))->Vitest.Expect.toEqual((
      true,
      Some("true"),
      Some("[\"widgets\",\"edges\"]"),
      true,
      "INFO FOR DB",
      "INFO FOR TABLE widgets",
      "SELECT count() AS count FROM widgets GROUP ALL;",
      "INFO FOR TABLE widgets STRUCTURE",
      "INFO FOR DB STRUCTURE",
    ))
  })

  Vitest.testAsync("query collect, run, resolve, and stream surfaces execute through the public API", async t => {
    let db = Surrealdb_Surreal.make()
    try {
      await connectServerDatabase(db)
      let queryable = db->Surrealdb_Surreal.asQueryable
      let bindings =
        Dict.fromArray([
          ("x", Surrealdb_JsValue.int(11)),
          ("y", Surrealdb_JsValue.int(12)),
        ])
      let bound = Surrealdb_Query.statement("RETURN $x; RETURN $y;", bindings)

      let collected =
        await queryable
        ->Surrealdb_Query.textOn("RETURN 1; RETURN 2;", ())
        ->Surrealdb_Query.collect
      let collectedIndexes =
        await queryable
        ->Surrealdb_Query.textOn("RETURN 3; RETURN 4; RETURN 5;", ())
        ->Surrealdb_Query.collectIndexes([0, 2])
      let responsesIndexes =
        await queryable
        ->Surrealdb_Query.textOn("RETURN 6; RETURN 7;", ())
        ->Surrealdb_Query.responsesIndexes([1])
      let runTextOn = await queryable->Surrealdb_Query.runTextOn("RETURN 8;")
      let runText = await db->Surrealdb_Query.runText("RETURN 9;")
      let runBoundOn = await queryable->Surrealdb_Query.runBoundOn(bound)
      let runBound = await db->Surrealdb_Query.runBound(bound)
      let runStatementOn = await queryable->Surrealdb_Query.runStatementOn(bound)
      let runStatement = await db->Surrealdb_Query.runStatement(bound)
      let runStatementTextOn = await queryable->Surrealdb_Query.runStatementTextOn("RETURN 10;")
      let runStatementText = await db->Surrealdb_Query.runStatementText("RETURN 11;")
      let resolved =
        await queryable
        ->Surrealdb_Query.textOn("RETURN 12;", ())
        ->Surrealdb_Query.resolve
      let thenResolved =
        await queryable
        ->Surrealdb_Query.textOn("RETURN 13;", ())
        ->Surrealdb_Query.thenResolve(values => values)
      let resolvedJson =
        await queryable
        ->Surrealdb_Query.textOn("RETURN { ok: true };", ())
        ->Surrealdb_Query.json
        ->Surrealdb_Query.resolveJson
      let thenResolvedJson =
        await queryable
        ->Surrealdb_Query.textOn("RETURN { ok: false };", ())
        ->Surrealdb_Query.json
        ->Surrealdb_Query.thenResolveJson(values => values)
      let streamTextFrames =
        await queryable
        ->Surrealdb_Query.streamTextOn("RETURN 14;")
        ->Surrealdb_AsyncIterable.collect
      let streamBoundFrames =
        await db
        ->Surrealdb_Query.streamBound(bound)
        ->Surrealdb_AsyncIterable.collect
      let streamStatementFrames =
        await db
        ->Surrealdb_Query.streamStatement(bound)
        ->Surrealdb_AsyncIterable.collect

      t->Vitest.expect((
        collected->Array.map(Surrealdb_Value.toText),
        collectedIndexes->Array.map(Surrealdb_Value.toText),
        responsesIndexes->Array.length,
        responsesIndexes->Array.get(0)->Option.flatMap(Surrealdb_QueryResponse.type_),
        runTextOn->Array.map(Surrealdb_Value.toText),
        runText->Array.map(Surrealdb_Value.toText),
        runBoundOn->Array.map(Surrealdb_Value.toText),
        runBound->Array.map(Surrealdb_Value.toText),
        runStatementOn->Array.map(Surrealdb_Value.toText),
        runStatement->Array.map(Surrealdb_Value.toText),
        runStatementTextOn->Array.map(Surrealdb_Value.toText),
        runStatementText->Array.map(Surrealdb_Value.toText),
        resolved->Array.map(Surrealdb_Value.toText),
        thenResolved->Array.map(Surrealdb_Value.toText),
        resolvedJson->Array.map(json => json->JSON.stringifyAny->Option.getOr("")),
        thenResolvedJson->Array.map(json => json->JSON.stringifyAny->Option.getOr("")),
        streamTextFrames->Array.length,
        streamBoundFrames->Array.length,
        streamStatementFrames->Array.length,
      ))->Vitest.Expect.toEqual((
        ["1", "2"],
        ["3", "5"],
        1,
        Some(Surrealdb_QueryType.Other),
        ["8"],
        ["9"],
        ["11", "12"],
        ["11", "12"],
        ["11", "12"],
        ["11", "12"],
        ["10"],
        ["11"],
        ["12"],
        ["13"],
        ["{\"ok\":true}"],
        ["{\"ok\":false}"],
        2,
        4,
        4,
      ))

      await closeIgnore(db)
    } catch {
    | error =>
      await closeIgnore(db)
      throw(error)
    }
  })

  Vitest.testAsync("run, auth, and export surfaces execute through the public API", async t => {
    let db = Surrealdb_Surreal.make()
    let authTable = "auth_user"
    let authAccess = "account_test"
    let authEmail = `auth-${Surrealdb_Uuid.v4()->Surrealdb_Uuid.toString}@example.com`
    try {
      await connectServerDatabase(db)
      let queryable = db->Surrealdb_Surreal.asQueryable
      let joined =
        await queryable
        ->Surrealdb_Run.callOn("string::join", ~args=[
            [Surrealdb_JsValue.string("a"), Surrealdb_JsValue.string("b")]->Surrealdb_JsValue.array,
            Surrealdb_JsValue.string("-"),
          ], ())
        ->Surrealdb_Run.resolve
      let runResolved =
        await queryable
        ->Surrealdb_Run.callOn("string::len", ~args=[Surrealdb_JsValue.string("alpha")], ())
        ->Surrealdb_Run.resolve
      let runThenResolved =
        await queryable
        ->Surrealdb_Run.callOn("string::len", ~args=[Surrealdb_JsValue.string("alpha")], ())
        ->Surrealdb_Run.thenResolve(value => value)
      let runJson =
        await queryable
        ->Surrealdb_Run.callOn("string::len", ~args=[Surrealdb_JsValue.string("alpha")], ())
        ->Surrealdb_Run.json
        ->Surrealdb_Run.resolveJson
      let runStream =
        await queryable
        ->Surrealdb_Run.callOn("string::len", ~args=[Surrealdb_JsValue.string("alpha")], ())
        ->Surrealdb_Run.stream
        ->Surrealdb_AsyncIterable.collect
      ignore(
        await db->Surrealdb_Query.runText(
          `DEFINE TABLE OVERWRITE ${authTable} PERMISSIONS FULL;
DEFINE ACCESS OVERWRITE ${authAccess} ON DATABASE TYPE RECORD
  SIGNUP ( CREATE ${authTable} SET email = $email, pass = crypto::argon2::generate($pass) )
  SIGNIN ( SELECT * FROM ${authTable} WHERE email = $email AND crypto::argon2::compare(pass, $pass) )
  DURATION FOR TOKEN 15m, FOR SESSION 12h;`,
        ),
      )
      let authSession = await db->Surrealdb_Surreal.newSession
      ignore(await authSession->Surrealdb_Session.useDatabase(namespaceDatabaseSelection()))
      ignore(
        await authSession->Surrealdb_Session.signup(
          Surrealdb_Session.makeAccessRecordAuth(
            ~access=authAccess,
            ~variables=Dict.fromArray([
              ("email", Surrealdb_JsValue.string(authEmail)),
              ("pass", Surrealdb_JsValue.string("pw")),
            ]),
            (),
          ),
        ),
      )
      let authQueryable = authSession->Surrealdb_Session.asQueryable
      let authResolved =
        await authQueryable
        ->Surrealdb_Queryable.auth
        ->Surrealdb_Auth.resolve
      let authResolvedJson =
        await authQueryable
        ->Surrealdb_Queryable.auth
        ->Surrealdb_Auth.json
        ->Surrealdb_Auth.resolveJson
      let authThenResolved =
        await authQueryable
        ->Surrealdb_Queryable.auth
        ->Surrealdb_Auth.thenResolve(value => value)
      let authStream =
        await authQueryable
        ->Surrealdb_Queryable.auth
        ->Surrealdb_Auth.stream
        ->Surrealdb_AsyncIterable.collect
      let exportSql =
        await db
        ->Surrealdb_Export.exportSqlDefault
        ->Surrealdb_Export.thenSql(value => value)
      let exportSqlFiltered =
        await db
        ->Surrealdb_Export.exportSql(
            Surrealdb_Export.sqlOptions(~tables=Surrealdb_Export.OnlyTables(["widgets"]), ()),
          )
        ->Surrealdb_Export.awaitSql
      let exportRawResponse =
        db
        ->Surrealdb_Export.exportSqlDefault
        ->Surrealdb_Export.rawSql
      let exportRawResolved =
        await exportRawResponse->Surrealdb_Export.awaitSql
      let exportRawStatus =
        exportRawResolved->responseStatus
      let authResolvedText =
        authResolved->Surrealdb_Value.toJSON->JSON.stringifyAny->Option.getOr("")
      let authResolvedJsonText =
        authResolvedJson->JSON.stringifyAny->Option.getOr("")
      let authThenResolvedText =
        authThenResolved->Surrealdb_Value.toJSON->JSON.stringifyAny->Option.getOr("")

      t->Vitest.expect((
        joined->Surrealdb_Value.toText,
        runResolved->Surrealdb_Value.toText,
        runThenResolved->Surrealdb_Value.toText,
        runJson->JSON.stringifyAny->Option.getOr(""),
        runStream->Array.length,
        authResolvedText->String.includes(authEmail),
        authResolvedJsonText->String.includes(authEmail),
        authThenResolvedText->String.includes(authEmail),
        authStream->Array.length >= 1,
        exportSql != "",
        exportSqlFiltered != "",
        exportRawStatus,
      ))->Vitest.Expect.toEqual((
        "-",
        "5",
        "5",
        "5",
        2,
        true,
        true,
        true,
        true,
        true,
        true,
        200,
      ))

      await authSession->Surrealdb_Session.close
      await closeIgnore(db)
    } catch {
    | error =>
      await closeIgnore(db)
      throw(error)
    }
  })

  Vitest.test("mutation builders keep their explicit public surfaces", t => {
    let db = CoverageSupport.makeDisconnectedDb()
    let table = Surrealdb_Table.make("widgets")
    let edgeTable = Surrealdb_Table.make("related_to")
    let recordId = Surrealdb_RecordId.make("widgets", "alpha")
    let recordId2 = Surrealdb_RecordId.make("widgets", "beta")
    let range = Surrealdb_RecordIdRange.make(
      ~table="widgets",
      ~begin=Surrealdb_RangeBound.included(Surrealdb_RangeBound.String("a")),
      ~end=Surrealdb_RangeBound.excluded(Surrealdb_RangeBound.String("z")),
      (),
    )
    let data =
      Dict.fromArray([
        ("label", Surrealdb_JsValue.string("alpha")),
        ("count", Surrealdb_JsValue.int(3)),
      ])
    let patchValue =
      Surrealdb_JsValue.object(Dict.fromArray([("ok", Surrealdb_JsValue.bool(true))]))
    let condition = Surrealdb_Expr.eq("status", Surrealdb_JsValue.string("active"))
    let createCompiled =
      db
      ->Surrealdb_Create.fromRecordId(recordId)
      ->Surrealdb_Create.content(data)
      ->Surrealdb_Create.patch(patchValue)
      ->Surrealdb_Create.output(Surrealdb_Output.After)
      ->Surrealdb_Create.json
      ->Surrealdb_Create.compile
    let deleteCompiled =
      db
      ->Surrealdb_Delete.fromRange(range)
      ->Surrealdb_Delete.output(Surrealdb_Output.Before)
      ->Surrealdb_Delete.json
      ->Surrealdb_Delete.compile
    let insertCompiled =
      db
      ->Surrealdb_Insert.intoTable(table, Surrealdb_JsValue.object(data))
      ->Surrealdb_Insert.relation
      ->Surrealdb_Insert.ignore
      ->Surrealdb_Insert.output(Surrealdb_Output.After)
      ->Surrealdb_Insert.json
      ->Surrealdb_Insert.compile
    let updateCompiled =
      db
      ->Surrealdb_Update.fromTable(table)
      ->Surrealdb_Update.content(data)
      ->Surrealdb_Update.merge(data)
      ->Surrealdb_Update.replace(data)
      ->Surrealdb_Update.patch(patchValue)
      ->Surrealdb_Update.where(condition)
      ->Surrealdb_Update.output(Surrealdb_Output.After)
      ->Surrealdb_Update.json
      ->Surrealdb_Update.compile
    let upsertCompiled =
      db
      ->Surrealdb_Upsert.fromRecordId(recordId)
      ->Surrealdb_Upsert.content(data)
      ->Surrealdb_Upsert.merge(data)
      ->Surrealdb_Upsert.replace(data)
      ->Surrealdb_Upsert.patch(patchValue)
      ->Surrealdb_Upsert.where(condition)
      ->Surrealdb_Upsert.output(Surrealdb_Output.After)
      ->Surrealdb_Upsert.json
      ->Surrealdb_Upsert.compile
    let relateCompiled =
      db
      ->Surrealdb_Relate.records(
          recordId,
          edgeTable,
          recordId2,
          ~data=data,
          (),
        )
      ->Surrealdb_Relate.unique
      ->Surrealdb_Relate.output(Surrealdb_Output.After)
      ->Surrealdb_Relate.version(Surrealdb_DateTime.fromString("2024-01-02T03:04:05Z"))
      ->Surrealdb_Relate.json
      ->Surrealdb_Relate.compile

    t->Vitest.expect((
      createCompiled->Surrealdb_BoundQuery.query->normalizeBindSlots,
      createCompiled->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length,
      deleteCompiled->Surrealdb_BoundQuery.query->normalizeBindSlots,
      deleteCompiled->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length,
      insertCompiled->Surrealdb_BoundQuery.query->normalizeBindSlots,
      insertCompiled->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length,
      updateCompiled->Surrealdb_BoundQuery.query->normalizeBindSlots,
      updateCompiled->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length,
      upsertCompiled->Surrealdb_BoundQuery.query->normalizeBindSlots,
      upsertCompiled->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length,
      relateCompiled->Surrealdb_BoundQuery.query->normalizeBindSlots,
      relateCompiled->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length,
    ))->Vitest.Expect.toEqual((
      "CREATE ONLY $bind__ PATCH $bind__ RETURN AFTER",
      2,
      "DELETE $bind__ RETURN BEFORE",
      1,
      "INSERT RELATION IGNORE INTO $bind__ $bind__ RETURN AFTER",
      2,
      "UPDATE $bind__ PATCH $bind__ WHERE status = $bind__ RETURN AFTER",
      3,
      "UPSERT ONLY $bind__ PATCH $bind__ WHERE status = $bind__ RETURN AFTER",
      3,
      "RELATE  ONLY $bind__ CONTENT $bind__ RETURN AFTER VERSION $bind__",
      5,
    ))
  })

  Vitest.testAsync("mutation builders resolve and stream through the live server path", async t => {
    let db = Surrealdb_Surreal.make()
    let tableName = "mutation_coverage"
    let edgeTableName = "related_to_coverage"
    let table = Surrealdb_Table.make(tableName)
    let edgeTable = Surrealdb_Table.make(edgeTableName)
    let recordId = Surrealdb_RecordId.make(tableName, "alpha")
    let otherRecordId = Surrealdb_RecordId.make(tableName, "beta")
    let data =
      Dict.fromArray([
        ("label", Surrealdb_JsValue.string("alpha")),
        ("count", Surrealdb_JsValue.int(3)),
      ])
    try {
      await connectServerDatabase(db)
      await removeTableIgnore(db, tableName)
      await removeTableIgnore(db, edgeTableName)
      ignore(await db->Surrealdb_Query.runText(`DEFINE TABLE ${tableName} SCHEMALESS;`))
      ignore(await db->Surrealdb_Query.runText(`DEFINE TABLE ${edgeTableName} TYPE RELATION SCHEMALESS;`))

      let createResolved =
        await db
        ->Surrealdb_Create.fromTable(table)
        ->Surrealdb_Create.content(data)
        ->Surrealdb_Create.resolve
      let createStream =
        await db
        ->Surrealdb_Create.fromTable(table)
        ->Surrealdb_Create.content(data)
        ->Surrealdb_Create.stream
        ->Surrealdb_AsyncIterable.collect
      let updateResolved =
        await db
        ->Surrealdb_Update.fromTable(table)
        ->Surrealdb_Update.content(data)
        ->Surrealdb_Update.where(Surrealdb_Expr.eq("label", Surrealdb_JsValue.string("alpha")))
        ->Surrealdb_Update.resolve
      let deleteResolved =
        await db
        ->Surrealdb_Delete.fromTable(table)
        ->Surrealdb_Delete.resolve
      let upsertResolved =
        await db
        ->Surrealdb_Upsert.fromTable(table)
        ->Surrealdb_Upsert.content(data)
        ->Surrealdb_Upsert.resolve
      let relateResolved =
        await db
        ->Surrealdb_Relate.records(
            recordId,
            edgeTable,
            otherRecordId,
            ~data=data,
            (),
          )
        ->Surrealdb_Relate.resolve
      let relateStream =
        await db
        ->Surrealdb_Relate.recordArrays(
            [recordId],
            edgeTable,
            [otherRecordId],
            ~data=data,
            (),
          )
        ->Surrealdb_Relate.stream
        ->Surrealdb_AsyncIterable.collect

      t->Vitest.expect((
        firstObjectFieldText(createResolved, "label"),
        firstObjectFieldText(createResolved, "count"),
        createStream->Array.length,
        createStream->Array.get(0)->Option.map(Surrealdb_QueryFrame.query),
        createStream->Array.get(0)->Option.flatMap(frame => frameObjectFieldText(~frame, ~fieldName="label")),
        createStream->Array.get(0)->Option.flatMap(frame => frameObjectFieldText(~frame, ~fieldName="count")),
        createStream->Array.get(1)->Option.flatMap(frameDoneType),
        arrayObjectFieldTexts(updateResolved, "label"),
        arrayObjectFieldTexts(updateResolved, "count"),
        arrayObjectFieldTexts(deleteResolved, "label"),
        arrayObjectFieldTexts(deleteResolved, "count"),
        firstObjectFieldText(upsertResolved, "label"),
        firstObjectFieldText(upsertResolved, "count"),
        objectFieldText(relateResolved, "label"),
        objectFieldText(relateResolved, "count"),
        objectFieldText(relateResolved, "in"),
        objectFieldText(relateResolved, "out"),
        relateStream->Array.length,
        relateStream->Array.get(0)->Option.map(Surrealdb_QueryFrame.query),
        relateStream->Array.get(0)->Option.flatMap(frame => frameObjectFieldText(~frame, ~fieldName="label")),
        relateStream->Array.get(0)->Option.flatMap(frame => frameObjectFieldText(~frame, ~fieldName="count")),
        relateStream->Array.get(0)->Option.flatMap(frame => frameObjectFieldText(~frame, ~fieldName="in")),
        relateStream->Array.get(0)->Option.flatMap(frame => frameObjectFieldText(~frame, ~fieldName="out")),
        relateStream->Array.get(1)->Option.flatMap(frameDoneType),
      ))->Vitest.Expect.toEqual((
        Some("alpha"),
        Some("3"),
        2,
        Some(0),
        Some("alpha"),
        Some("3"),
        Some(Surrealdb_QueryType.Other),
        [Some("alpha"), Some("alpha")],
        [Some("3"), Some("3")],
        [Some("alpha"), Some("alpha")],
        [Some("3"), Some("3")],
        Some("alpha"),
        Some("3"),
        Some("alpha"),
        Some("3"),
        Some("mutation_coverage:alpha"),
        Some("mutation_coverage:beta"),
        2,
        Some(0),
        Some("alpha"),
        Some("3"),
        Some("mutation_coverage:alpha"),
        Some("mutation_coverage:beta"),
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
