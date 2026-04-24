module CoverageSupport = SurrealdbCoverageTestSupport

let makeDisconnectedDb = CoverageSupport.makeDisconnectedDb

Vitest.describe("SurrealDB query compile surface", () => {
  Vitest.test("relate overloads allow omitted data and array inputs on the installed public SDK surface", t => {
    let db = makeDisconnectedDb()
    let fromRecord = Surrealdb_RecordId.make("widgets", "a")
    let toRecord = Surrealdb_RecordId.make("widgets", "b")
    let edgeTable = Surrealdb_Table.make("rel")
    let singleNoData =
      db->Surrealdb_Relate.records(fromRecord, edgeTable, toRecord, ())->Surrealdb_Relate.compile
    let singleWithData =
      db
      ->Surrealdb_Relate.records(
          fromRecord,
          edgeTable,
          toRecord,
          ~data=Dict.fromArray([("weight", Surrealdb_JsValue.int(1))]),
          (),
        )
      ->Surrealdb_Relate.compile
    let multiNoData =
      db
      ->Surrealdb_Relate.recordArrays([fromRecord], edgeTable, [toRecord], ())
      ->Surrealdb_Relate.compile

    t->Vitest.expect((
      String.startsWith(singleNoData->Surrealdb_BoundQuery.query, "RELATE  ONLY $bind__"),
      singleNoData->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length,
      singleWithData->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length,
      String.startsWith(multiNoData->Surrealdb_BoundQuery.query, "RELATE  $bind__"),
      multiNoData->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length,
    ))->Vitest.Expect.toEqual((true, 3, 4, true, 3))
  })

  Vitest.test("query, run, and select compile omitted optional arguments on the installed public SDK surface", t => {
    let db = makeDisconnectedDb()
    let queryable = db->Surrealdb_Surreal.asQueryable
    let query = db->Surrealdb_Query.text("RETURN 1;", ())
    let runCompiled = queryable->Surrealdb_Run.callOn("string::len", ())->Surrealdb_Run.compile
    let runJsonCompiled =
      queryable->Surrealdb_Run.callOn("string::len", ())->Surrealdb_Run.json->Surrealdb_Run.compile
    let versionedRunCompiled =
      queryable
      ->Surrealdb_Run.callVersionedOn("string::len", "1.0.0", ())
      ->Surrealdb_Run.compile
    let selectJsonCompiled =
      queryable->Surrealdb_Select.tableOn("widgets")->Surrealdb_Select.json->Surrealdb_Select.compile

    t->Vitest.expect((
      query->Surrealdb_Query.inner->Surrealdb_BoundQuery.query,
      query->Surrealdb_Query.inner->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length,
      runCompiled->Surrealdb_BoundQuery.query,
      runJsonCompiled->Surrealdb_BoundQuery.query,
      versionedRunCompiled->Surrealdb_BoundQuery.query,
      String.startsWith(selectJsonCompiled->Surrealdb_BoundQuery.query, "SELECT * FROM $bind__"),
    ))->Vitest.Expect.toEqual((
      "RETURN 1;",
      0,
      "string::len()",
      "string::len()",
      "string::len<1.0.0>()",
      true,
    ))
  })
})
