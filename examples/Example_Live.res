// examples/Example_Live.res — create a managed live subscription.
// Concern: demonstrate the live-query builder surface from the package root.

let subscribe = async () => {
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
  let subscription =
    await db
    ->Surrealdb.Connection.Surreal.asQueryable
    ->Surrealdb.Live.Builder.tableNamedOn("widgets")
    ->Surrealdb.Live.Builder.awaitManaged
  let queryId = subscription->Surrealdb.Live.Subscription.id->Surrealdb.Values.Uuid.toString
  await subscription->Surrealdb.Live.Subscription.kill
  let _ = await db->Surrealdb.Connection.Surreal.close
  queryId
}
