module Support = SurrealdbCoverageTestSupport

let makeDisconnectedDb = Support.makeDisconnectedDb
let toUnknown = SurrealdbTestCasts.toUnknown

Vitest.describe("SurrealDB query builder coverage", () => {
  Vitest.test("query builders and overloads compile across the narrowed public surface", t => {
    let db = makeDisconnectedDb()
    let queryable = db->Surrealdb_Surreal.asQueryable
    let table = Surrealdb_Table.make("widgets")
    let fromRecord = Surrealdb_RecordId.make("users", "alice")
    let toRecord = Surrealdb_RecordId.make("users", "bob")
    let singleRecord = Surrealdb_RecordId.make("widgets", "alpha")
    let edgeTable = Surrealdb_Table.make("likes")
    let range =
      Surrealdb_RecordIdRange.make(
        ~table="widgets",
        ~begin=Surrealdb_RangeBound.included(Surrealdb_RangeBound.String("a")),
        ~end=Surrealdb_RangeBound.excluded(Surrealdb_RangeBound.String("z")),
        (),
      )
    let payload =
      Dict.fromArray([
        ("label", Surrealdb_JsValue.string("alpha")),
        ("count", Surrealdb_JsValue.int(3)),
      ])
    let patchValue =
      Dict.fromArray([
        ("op", Surrealdb_JsValue.string("replace")),
        ("path", Surrealdb_JsValue.string("/label")),
        ("value", Surrealdb_JsValue.string("beta")),
      ])->Surrealdb_JsValue.object
    let whereExpr = Surrealdb_Expr.eq("count", Surrealdb_JsValue.int(3))
    let version = Surrealdb_DateTime.fromString("2026-04-24T00:00:00.000Z")

    let selectCompiled =
      queryable
      ->Surrealdb_Select.fromTableOn(table)
      ->Surrealdb_Select.fields(["id", "label"])
      ->Surrealdb_Select.value("label")
      ->Surrealdb_Select.start(2)
      ->Surrealdb_Select.limit(5)
      ->Surrealdb_Select.where(whereExpr)
      ->Surrealdb_Select.fetch(["owner"])
      ->Surrealdb_Select.version(version)
      ->Surrealdb_Select.compile
    let selectRecordCompiled = queryable->Surrealdb_Select.recordOn("widgets", "alpha")->Surrealdb_Select.compile
    let selectRangeCompiled = queryable->Surrealdb_Select.fromRangeOn(range)->Surrealdb_Select.compile
    let createCompiled =
      queryable
      ->Surrealdb_Create.fromRecordIdOn(singleRecord)
      ->Surrealdb_Create.content(payload)
      ->Surrealdb_Create.patch(patchValue)
      ->Surrealdb_Create.version(version)
      ->Surrealdb_Create.output(Surrealdb_Output.After)
      ->Surrealdb_Create.compile
    let createTableCompiled = db->Surrealdb_Create.fromTable(table)->Surrealdb_Create.compile
    let updateCompiled =
      queryable
      ->Surrealdb_Update.fromRangeOn(range)
      ->Surrealdb_Update.content(payload)
      ->Surrealdb_Update.merge(payload)
      ->Surrealdb_Update.replace(payload)
      ->Surrealdb_Update.patch(patchValue)
      ->Surrealdb_Update.where(whereExpr)
      ->Surrealdb_Update.output(Surrealdb_Output.Before)
      ->Surrealdb_Update.compile
    let upsertCompiled =
      queryable
      ->Surrealdb_Upsert.fromRecordIdOn(singleRecord)
      ->Surrealdb_Upsert.content(payload)
      ->Surrealdb_Upsert.merge(payload)
      ->Surrealdb_Upsert.replace(payload)
      ->Surrealdb_Upsert.patch(patchValue)
      ->Surrealdb_Upsert.where(whereExpr)
      ->Surrealdb_Upsert.output(Surrealdb_Output.After)
      ->Surrealdb_Upsert.compile
    let deleteCompiled =
      queryable
      ->Surrealdb_Delete.fromRangeOn(range)
      ->Surrealdb_Delete.version(version)
      ->Surrealdb_Delete.output(Surrealdb_Output.Null)
      ->Surrealdb_Delete.compile
    let insertCompiled =
      queryable
      ->Surrealdb_Insert.intoTableOn(table, payload->Surrealdb_JsValue.object)
      ->Surrealdb_Insert.relation
      ->Surrealdb_Insert.ignore
      ->Surrealdb_Insert.version(version)
      ->Surrealdb_Insert.output(Surrealdb_Output.After)
      ->Surrealdb_Insert.compile
    let insertDataCompiled =
      db
      ->Surrealdb_Insert.fromData(payload->Surrealdb_JsValue.object)
      ->Surrealdb_Insert.compile
    let relateCompiled =
      queryable
      ->Surrealdb_Relate.recordWithDataOn(fromRecord, edgeTable, toRecord, payload)
      ->Surrealdb_Relate.unique
      ->Surrealdb_Relate.version(version)
      ->Surrealdb_Relate.output(Surrealdb_Output.Diff)
      ->Surrealdb_Relate.compile
    let relateArrayCompiled =
      db
      ->Surrealdb_Relate.recordArrays(
          [fromRecord],
          edgeTable,
          [toRecord],
          ~data=payload,
          (),
        )
      ->Surrealdb_Relate.compile
    let runCompiled =
      queryable
      ->Surrealdb_Run.versionedFunctionOn("string::join", "2.0.0", [
          Surrealdb_JsValue.array([Surrealdb_JsValue.string("a"), Surrealdb_JsValue.string("b")]),
          Surrealdb_JsValue.string("-"),
        ])
      ->Surrealdb_Run.compile
    let runNoArgsCompiled =
      db->Surrealdb_Run.versionedFunction("time::now", "2.0.0", ())->Surrealdb_Run.compile
    let liveCompiled =
      queryable
      ->Surrealdb_Live.tableNamedOn("widgets")
      ->Surrealdb_Live.diff
      ->Surrealdb_Live.fields(["id", "label"])
      ->Surrealdb_Live.value("label")
      ->Surrealdb_Live.where(whereExpr)
      ->Surrealdb_Live.fetch(["owner"])
      ->Surrealdb_Live.compile
    let liveOfBuilder =
      db->Surrealdb_Live.of_(Surrealdb_Uuid.fromString("018cc251-4f5c-7def-b4c6-000000000001"))

    t->Vitest.expect((
      selectCompiled->Surrealdb_BoundQuery.query->String.startsWith("SELECT VALUE"),
      selectRecordCompiled->Surrealdb_BoundQuery.query->String.startsWith("SELECT * FROM ONLY $bind__"),
      selectRangeCompiled->Surrealdb_BoundQuery.query->String.startsWith("SELECT * FROM $bind__"),
      createCompiled->Surrealdb_BoundQuery.query->String.includes("RETURN AFTER"),
      createTableCompiled->Surrealdb_BoundQuery.query->String.startsWith("CREATE $bind__"),
      updateCompiled->Surrealdb_BoundQuery.query->String.includes("RETURN BEFORE"),
      upsertCompiled->Surrealdb_BoundQuery.query->String.includes("RETURN AFTER"),
      deleteCompiled->Surrealdb_BoundQuery.query->String.includes("RETURN null"),
      insertCompiled->Surrealdb_BoundQuery.query->String.includes("RELATION IGNORE"),
      insertDataCompiled->Surrealdb_BoundQuery.query->String.startsWith("INSERT $bind__"),
      relateCompiled->Surrealdb_BoundQuery.query->String.includes("RETURN DIFF"),
      relateArrayCompiled->Surrealdb_BoundQuery.query->String.startsWith("RELATE  $bind__"),
      runCompiled->Surrealdb_BoundQuery.query->String.startsWith("string::join<2.0.0>"),
      runNoArgsCompiled->Surrealdb_BoundQuery.query->String.startsWith("time::now<2.0.0>()"),
      liveCompiled->Surrealdb_BoundQuery.query->String.startsWith("LIVE SELECT VALUE"),
      liveOfBuilder->toUnknown !== db->toUnknown,
    ))->Vitest.Expect.toEqual((
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
    ))
  })

  Vitest.test("expression builders keep the operator surface callable", t => {
    let vector =
      [Surrealdb_JsValue.float(1.0), Surrealdb_JsValue.float(2.0), Surrealdb_JsValue.float(3.0)]
      ->Surrealdb_JsValue.array
    let values =
      [
        Surrealdb_Expr.raw("count > 0")->Surrealdb_Expr.toBoundQuery->Surrealdb_BoundQuery.query,
        Surrealdb_Expr.eq("count", Surrealdb_JsValue.int(1))->Surrealdb_Expr.toBoundQuery->Surrealdb_BoundQuery.query,
        Surrealdb_Expr.eeq("count", Surrealdb_JsValue.int(1))->Surrealdb_Expr.toBoundQuery->Surrealdb_BoundQuery.query,
        Surrealdb_Expr.ne("count", Surrealdb_JsValue.int(2))->Surrealdb_Expr.toBoundQuery->Surrealdb_BoundQuery.query,
        Surrealdb_Expr.gt("count", Surrealdb_JsValue.int(3))->Surrealdb_Expr.toBoundQuery->Surrealdb_BoundQuery.query,
        Surrealdb_Expr.gte("count", Surrealdb_JsValue.int(4))->Surrealdb_Expr.toBoundQuery->Surrealdb_BoundQuery.query,
        Surrealdb_Expr.lt("count", Surrealdb_JsValue.int(5))->Surrealdb_Expr.toBoundQuery->Surrealdb_BoundQuery.query,
        Surrealdb_Expr.lte("count", Surrealdb_JsValue.int(6))->Surrealdb_Expr.toBoundQuery->Surrealdb_BoundQuery.query,
        Surrealdb_Expr.contains("tags", Surrealdb_JsValue.string("a"))->Surrealdb_Expr.toBoundQuery->Surrealdb_BoundQuery.query,
        Surrealdb_Expr.containsAny("tags", vector)->Surrealdb_Expr.toBoundQuery->Surrealdb_BoundQuery.query,
        Surrealdb_Expr.containsAll("tags", vector)->Surrealdb_Expr.toBoundQuery->Surrealdb_BoundQuery.query,
        Surrealdb_Expr.containsNone("tags", vector)->Surrealdb_Expr.toBoundQuery->Surrealdb_BoundQuery.query,
        Surrealdb_Expr.inside("point", vector)->Surrealdb_Expr.toBoundQuery->Surrealdb_BoundQuery.query,
        Surrealdb_Expr.outside("point", vector)->Surrealdb_Expr.toBoundQuery->Surrealdb_BoundQuery.query,
        Surrealdb_Expr.intersects("geom", vector)->Surrealdb_Expr.toBoundQuery->Surrealdb_BoundQuery.query,
        Surrealdb_Expr.matches("name", "/a.*/")->Surrealdb_Expr.toBoundQuery->Surrealdb_BoundQuery.query,
        Surrealdb_Expr.matchesWithRef("name", "/a.*/", 0)->Surrealdb_Expr.toBoundQuery->Surrealdb_BoundQuery.query,
        Surrealdb_Expr.knn("embedding", vector, 10)->Surrealdb_Expr.toBoundQuery->Surrealdb_BoundQuery.query,
        Surrealdb_Expr.knnWithMetric("embedding", vector, 10, "COSINE")->Surrealdb_Expr.toBoundQuery->Surrealdb_BoundQuery.query,
        Surrealdb_Expr.knnWithEf("embedding", vector, 10, 50)->Surrealdb_Expr.toBoundQuery->Surrealdb_BoundQuery.query,
        Surrealdb_Expr.between("count", Surrealdb_JsValue.int(1), Surrealdb_JsValue.int(10))->Surrealdb_Expr.toBoundQuery->Surrealdb_BoundQuery.query,
        Surrealdb_Expr.and_([
          Surrealdb_Expr.eq("a", Surrealdb_JsValue.int(1)),
          Surrealdb_Expr.eq("b", Surrealdb_JsValue.int(2)),
        ])->Surrealdb_Expr.toBoundQuery->Surrealdb_BoundQuery.query,
        Surrealdb_Expr.or_([
          Surrealdb_Expr.eq("a", Surrealdb_JsValue.int(1)),
          Surrealdb_Expr.eq("b", Surrealdb_JsValue.int(2)),
        ])->Surrealdb_Expr.toBoundQuery->Surrealdb_BoundQuery.query,
        Surrealdb_Expr.not_(Surrealdb_Expr.eq("flag", Surrealdb_JsValue.bool(true)))->Surrealdb_Expr.toBoundQuery->Surrealdb_BoundQuery.query,
      ]

    t->Vitest.expect(values->Array.map(query =>
      query->String.includes("$bind__") || query == "count > 0" || query->String.includes("/a.*/")
    )->Array.every(value => value))->Vitest.Expect.toBe(true)
  })

})
