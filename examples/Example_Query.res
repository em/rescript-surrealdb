// examples/Example_Query.res — run a simple query through the package root.
// Concern: demonstrate query construction and result collection.

let run = async () => {
  let db = Surrealdb.Connection.Surreal.make()
  await Surrealdb.Connection.Surreal.connect(
    db,
    "ws://127.0.0.1:8787/rpc",
    ~namespace="test",
    ~database="rescript_surrealdb",
    ~authentication=
      Surrealdb.Connection.Surreal.rootConnectAuth(~username="root", ~password="root", ())
      ->Surrealdb.Connection.Surreal.staticAuthentication,
    ~versionCheck=false,
    (),
  )
  let values = await db->Surrealdb.Query.Query.text("RETURN 1; RETURN 2;", ())->Surrealdb.Query.Query.resolve
  let _ = await db->Surrealdb.Connection.Surreal.close
  values->Array.map(Surrealdb.Values.Value.toText)
}
