open TestRuntime

external stringToUnknown: string => unknown = "%identity"

describe("SurrealDB promise configurators", () => {
  let db = Surrealdb_Surreal.make()
  let queryable = db->Surrealdb_Surreal.asQueryable
  let version = Surrealdb_DateTime.fromString("2026-04-20T00:00:00.000Z")
  let timeout = Surrealdb_Duration.fromString("5s")

  test("create, delete, insert, and select compile the configured SDK clauses through the shared queryable helpers", () => {
    let createQuery = queryable
    ->Surrealdb_Create.recordOn("widgets", "alpha")
    ->Surrealdb_Create.content(Dict.fromArray([("name", Surrealdb_JsValue.string("Alpha"))]))
    ->Surrealdb_Create.output(Surrealdb_Output.After)
    ->Surrealdb_Create.timeout(timeout)
    ->Surrealdb_Create.version(version)
    ->Surrealdb_Create.compile

    let deleteQuery = queryable
    ->Surrealdb_Delete.recordOn("widgets", "alpha")
    ->Surrealdb_Delete.output(Surrealdb_Output.Before)
    ->Surrealdb_Delete.timeout(timeout)
    ->Surrealdb_Delete.version(version)
    ->Surrealdb_Delete.compile

    let insertPayload = [Surrealdb_JsValue.json(JSON.parseOrThrow("{\"name\":\"Alpha\"}"))]->Surrealdb_JsValue.array
    let insertQuery = queryable
    ->Surrealdb_Insert.tableOn("widgets", insertPayload)
    ->Surrealdb_Insert.relation
    ->Surrealdb_Insert.ignore
    ->Surrealdb_Insert.output(Surrealdb_Output.Diff)
    ->Surrealdb_Insert.timeout(timeout)
    ->Surrealdb_Insert.version(version)
    ->Surrealdb_Insert.compile

    let selectQuery = queryable
    ->Surrealdb_Select.tableOn("widgets")
    ->Surrealdb_Select.where(Surrealdb_Expr.eq("name", stringToUnknown("Alpha")))
    ->Surrealdb_Select.timeout(timeout)
    ->Surrealdb_Select.version(version)
    ->Surrealdb_Select.compile

    (
      createQuery->Surrealdb_BoundQuery.query,
      createQuery->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length,
      deleteQuery->Surrealdb_BoundQuery.query,
      deleteQuery->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length,
      insertQuery->Surrealdb_BoundQuery.query,
      insertQuery->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length,
      selectQuery->Surrealdb_BoundQuery.query,
      selectQuery->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length,
    )
    ->Expect.expect
    ->Expect.toEqual((
      "CREATE ONLY $bind__1 CONTENT $bind__2 RETURN AFTER TIMEOUT TIMEOUT 5s VERSION $bind__3",
      3,
      "DELETE ONLY $bind__4 RETURN BEFORE TIMEOUT TIMEOUT 5s VERSION $bind__5",
      2,
      "INSERT RELATION IGNORE INTO $bind__6 $bind__7 RETURN DIFF TIMEOUT TIMEOUT 5s VERSION $bind__8",
      3,
      "SELECT * FROM $bind__9 WHERE name = $bind__10 TIMEOUT TIMEOUT 5s VERSION $bind__11",
      3,
    ))
  })

  test("update, upsert, and relate compile the configured SDK clauses through the shared queryable helpers", () => {
    let updateQuery = queryable
    ->Surrealdb_Update.recordOn("widgets", "alpha")
    ->Surrealdb_Update.merge(Dict.fromArray([("count", Surrealdb_JsValue.int(3))]))
    ->Surrealdb_Update.output(Surrealdb_Output.After)
    ->Surrealdb_Update.timeout(timeout)
    ->Surrealdb_Update.compile

    let upsertQuery = queryable
    ->Surrealdb_Upsert.recordOn("widgets", "alpha")
    ->Surrealdb_Upsert.replace(Dict.fromArray([("count", Surrealdb_JsValue.int(4))]))
    ->Surrealdb_Upsert.output(Surrealdb_Output.Null)
    ->Surrealdb_Upsert.timeout(timeout)
    ->Surrealdb_Upsert.compile

    let relateQuery = queryable
    ->Surrealdb_Relate.recordsOn(
      Surrealdb_RecordId.make("widgets", "alpha"),
      Surrealdb_Table.make("links"),
      Surrealdb_RecordId.make("widgets", "beta"),
      ~data=Dict.fromArray([("strength", Surrealdb_JsValue.int(1))]),
      (),
    )
    ->Surrealdb_Relate.unique
    ->Surrealdb_Relate.output(Surrealdb_Output.After)
    ->Surrealdb_Relate.timeout(timeout)
    ->Surrealdb_Relate.version(version)
    ->Surrealdb_Relate.compile

    (
      updateQuery->Surrealdb_BoundQuery.query,
      updateQuery->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length,
      upsertQuery->Surrealdb_BoundQuery.query,
      upsertQuery->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length,
      relateQuery->Surrealdb_BoundQuery.query,
      relateQuery->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length,
    )
    ->Expect.expect
    ->Expect.toEqual((
      "UPDATE ONLY $bind__12 MERGE $bind__13 RETURN AFTER TIMEOUT TIMEOUT 5s",
      2,
      "UPSERT ONLY $bind__14 REPLACE $bind__15 RETURN null TIMEOUT TIMEOUT 5s",
      2,
      "RELATE  ONLY $bind__16->$bind__17->$bind__18 CONTENT $bind__19 RETURN AFTER TIMEOUT TIMEOUT 5s VERSION $bind__20",
      5,
    ))
  })
})
