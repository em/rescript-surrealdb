module SessionSupport = SurrealdbSessionTestSupport
module CoverageSupport = SurrealdbCoverageTestSupport

let closeIgnore = SessionSupport.closeIgnore
let connectServerDatabase = SessionSupport.connectServerDatabase
let namespaceDatabaseSelection = SessionSupport.namespaceDatabaseSelection
let responseStatus = SessionSupport.responseStatus
let hasField = CoverageSupport.hasField
let dictFieldText = CoverageSupport.dictFieldText

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

  Vitest.testAsync("query helpers execute across collect, run, resolve, and stream wrappers", async t => {
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

  Vitest.testAsync("run, auth, and export wrappers execute through the public surface", async t => {
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
})
