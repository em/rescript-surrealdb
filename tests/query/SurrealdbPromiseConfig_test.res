let cwd = () => NodeJs.Process.process->NodeJs.Process.cwd

let fileText = parts =>
  NodeJs.Path.join([cwd(), ...parts])->NodeJs.Fs.readFileSync->NodeJs.Buffer.toString

let filesContaining = (~files, ~pattern) =>
  files->Belt.Array.keepMap(((path, parts)) =>
    if fileText(parts)->String.includes(pattern) {
      Some(path)
    } else {
      None
    }
  )

Vitest.describe("SurrealDB promise configurators", () => {
  let db = Surrealdb_Surreal.make()
  let queryable = db->Surrealdb_Surreal.asQueryable
  let version = Surrealdb_DateTime.fromString("2026-04-20T00:00:00.000Z")

  Vitest.test("create, delete, insert, and select compile the remaining supported SDK clauses through the shared queryable path", t => {
    let createQuery = queryable
    ->Surrealdb_Create.recordOn("widgets", "alpha")
    ->Surrealdb_Create.content(Dict.fromArray([("name", Surrealdb_JsValue.string("Alpha"))]))
    ->Surrealdb_Create.output(Surrealdb_Output.After)
    ->Surrealdb_Create.version(version)
    ->Surrealdb_Create.compile

    let deleteQuery = queryable
    ->Surrealdb_Delete.recordOn("widgets", "alpha")
    ->Surrealdb_Delete.output(Surrealdb_Output.Before)
    ->Surrealdb_Delete.version(version)
    ->Surrealdb_Delete.compile

    let insertPayload = [Surrealdb_JsValue.json(JSON.parseOrThrow("{\"name\":\"Alpha\"}"))]->Surrealdb_JsValue.array
    let insertQuery = queryable
    ->Surrealdb_Insert.tableOn("widgets", insertPayload)
    ->Surrealdb_Insert.relation
    ->Surrealdb_Insert.ignore
    ->Surrealdb_Insert.output(Surrealdb_Output.Diff)
    ->Surrealdb_Insert.version(version)
    ->Surrealdb_Insert.compile

    let selectQuery = queryable
    ->Surrealdb_Select.tableOn("widgets")
    ->Surrealdb_Select.where(Surrealdb_Expr.eq("name", Surrealdb_JsValue.string("Alpha")))
    ->Surrealdb_Select.version(version)
    ->Surrealdb_Select.compile

    t->Vitest.expect((
      createQuery->Surrealdb_BoundQuery.query,
      createQuery->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length,
      deleteQuery->Surrealdb_BoundQuery.query,
      deleteQuery->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length,
      insertQuery->Surrealdb_BoundQuery.query,
      insertQuery->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length,
      selectQuery->Surrealdb_BoundQuery.query,
      selectQuery->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length,
    ))
    ->Vitest.Expect.toEqual((
      "CREATE ONLY $bind__1 CONTENT $bind__2 RETURN AFTER VERSION $bind__3",
      3,
      "DELETE ONLY $bind__4 RETURN BEFORE VERSION $bind__5",
      2,
      "INSERT RELATION IGNORE INTO $bind__6 $bind__7 RETURN DIFF VERSION $bind__8",
      3,
      "SELECT * FROM $bind__9 WHERE name = $bind__10 VERSION $bind__11",
      3,
    ))
  })

  Vitest.test("update, upsert, and relate compile the remaining supported SDK clauses through the shared queryable path", t => {
    let updateQuery = queryable
    ->Surrealdb_Update.recordOn("widgets", "alpha")
    ->Surrealdb_Update.merge(Dict.fromArray([("count", Surrealdb_JsValue.int(3))]))
    ->Surrealdb_Update.output(Surrealdb_Output.After)
    ->Surrealdb_Update.compile

    let upsertQuery = queryable
    ->Surrealdb_Upsert.recordOn("widgets", "alpha")
    ->Surrealdb_Upsert.replace(Dict.fromArray([("count", Surrealdb_JsValue.int(4))]))
    ->Surrealdb_Upsert.output(Surrealdb_Output.Null)
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
    ->Surrealdb_Relate.version(version)
    ->Surrealdb_Relate.compile

    t->Vitest.expect((
      updateQuery->Surrealdb_BoundQuery.query,
      updateQuery->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length,
      upsertQuery->Surrealdb_BoundQuery.query,
      upsertQuery->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length,
      relateQuery->Surrealdb_BoundQuery.query,
      relateQuery->Surrealdb_BoundQuery.bindings->Dict.toArray->Array.length,
    ))
    ->Vitest.Expect.toEqual((
      "UPDATE ONLY $bind__12 MERGE $bind__13 RETURN AFTER",
      2,
      "UPSERT ONLY $bind__14 REPLACE $bind__15 RETURN null",
      2,
      "RELATE  ONLY $bind__16->$bind__17->$bind__18 CONTENT $bind__19 RETURN AFTER VERSION $bind__20",
      5,
    ))
  })

  Vitest.test("timeout is absent from the public binding builders after narrowing the unsupported contract", t => {
    let resiFiles = [
      ("src/query/Surrealdb_Create.resi", ["src", "query", "Surrealdb_Create.resi"]),
      ("src/query/Surrealdb_Delete.resi", ["src", "query", "Surrealdb_Delete.resi"]),
      ("src/query/Surrealdb_Insert.resi", ["src", "query", "Surrealdb_Insert.resi"]),
      ("src/query/Surrealdb_Relate.resi", ["src", "query", "Surrealdb_Relate.resi"]),
      ("src/query/Surrealdb_Select.resi", ["src", "query", "Surrealdb_Select.resi"]),
      ("src/query/Surrealdb_Update.resi", ["src", "query", "Surrealdb_Update.resi"]),
      ("src/query/Surrealdb_Upsert.resi", ["src", "query", "Surrealdb_Upsert.resi"]),
    ]
    let jsFiles = [
      ("src/query/Surrealdb_Create.mjs", ["src", "query", "Surrealdb_Create.mjs"]),
      ("src/query/Surrealdb_Delete.mjs", ["src", "query", "Surrealdb_Delete.mjs"]),
      ("src/query/Surrealdb_Insert.mjs", ["src", "query", "Surrealdb_Insert.mjs"]),
      ("src/query/Surrealdb_Relate.mjs", ["src", "query", "Surrealdb_Relate.mjs"]),
      ("src/query/Surrealdb_Select.mjs", ["src", "query", "Surrealdb_Select.mjs"]),
      ("src/query/Surrealdb_Update.mjs", ["src", "query", "Surrealdb_Update.mjs"]),
      ("src/query/Surrealdb_Upsert.mjs", ["src", "query", "Surrealdb_Upsert.mjs"]),
    ]

    t->Vitest.expect((
      filesContaining(~files=resiFiles, ~pattern="let timeout:"),
      filesContaining(~files=jsFiles, ~pattern="function timeout("),
    ))
    ->Vitest.Expect.toEqual(([], []))
  })

  Vitest.test("raw string output setters are absent from the public mutation builders after narrowing to the closed output enum", t => {
    let resiFiles = [
      ("src/query/Surrealdb_Create.resi", ["src", "query", "Surrealdb_Create.resi"]),
      ("src/query/Surrealdb_Delete.resi", ["src", "query", "Surrealdb_Delete.resi"]),
      ("src/query/Surrealdb_Insert.resi", ["src", "query", "Surrealdb_Insert.resi"]),
      ("src/query/Surrealdb_Relate.resi", ["src", "query", "Surrealdb_Relate.resi"]),
      ("src/query/Surrealdb_Update.resi", ["src", "query", "Surrealdb_Update.resi"]),
      ("src/query/Surrealdb_Upsert.resi", ["src", "query", "Surrealdb_Upsert.resi"]),
    ]
    let jsFiles = [
      ("src/query/Surrealdb_Create.mjs", ["src", "query", "Surrealdb_Create.mjs"]),
      ("src/query/Surrealdb_Delete.mjs", ["src", "query", "Surrealdb_Delete.mjs"]),
      ("src/query/Surrealdb_Insert.mjs", ["src", "query", "Surrealdb_Insert.mjs"]),
      ("src/query/Surrealdb_Relate.mjs", ["src", "query", "Surrealdb_Relate.mjs"]),
      ("src/query/Surrealdb_Update.mjs", ["src", "query", "Surrealdb_Update.mjs"]),
      ("src/query/Surrealdb_Upsert.mjs", ["src", "query", "Surrealdb_Upsert.mjs"]),
    ]

    t->Vitest.expect((
      filesContaining(~files=resiFiles, ~pattern="let outputRaw:"),
      filesContaining(~files=jsFiles, ~pattern="function outputRaw("),
    ))
    ->Vitest.Expect.toEqual(([], []))
  })
})
