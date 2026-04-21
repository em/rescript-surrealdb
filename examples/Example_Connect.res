// examples/Example_Connect.res — connect and inspect connection state.
// Concern: demonstrate the public connection surface from the package root.

let make = async () => {
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
  let status = db->Surrealdb.Connection.Surreal.status
  let connected = db->Surrealdb.Connection.Surreal.isConnected
  let _ = await db->Surrealdb.Connection.Surreal.close
  (status, connected)
}
