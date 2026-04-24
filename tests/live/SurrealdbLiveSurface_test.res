module Support = SurrealdbSessionTestSupport

let closeIgnore = Support.closeIgnore
let removeTableIgnore = Support.removeTableIgnore
let connectServerDatabase = Support.connectServerDatabase
let liveMessageSummary = Support.liveMessageSummary

Vitest.describe("SurrealDB live surface", () => {
  Vitest.testAsync("managed and unmanaged live subscriptions classify on the installed public SDK surface", async t => {
    let db = Surrealdb_Surreal.make()
    let tableName = "widgets"
    let killIgnore = subscription =>
      subscription
      ->Surrealdb_LiveSubscription.kill
      ->Promise.catch(_ => Promise.resolve())

    try {
      await connectServerDatabase(db)
      await removeTableIgnore(db, tableName)
      ignore(await db->Surrealdb_Query.runText(`DEFINE TABLE ${tableName} SCHEMALESS;`))

      let managed =
        await db
        ->Surrealdb_Surreal.asQueryable
        ->Surrealdb_Live.tableNamedOn(tableName)
        ->Surrealdb_Live.awaitManaged
      let queryId =
        switch await db->Surrealdb_Query.text(`LIVE SELECT * FROM ${tableName}`, ())->Surrealdb_Query.resolve {
        | [Uuid(value)] => value
        | [rawValue] =>
          throw(Failure(`LIVE SELECT result did not return a Uuid: ${rawValue->Surrealdb_Value.toText}`))
        | _ => throw(Failure("LIVE SELECT did not return exactly one result"))
        }
      let unmanaged =
        await db
        ->Surrealdb_Surreal.asQueryable
        ->Surrealdb_Live.ofIdOn(queryId)
        ->Surrealdb_Live.awaitUnmanaged

      t->Vitest.expect((
        managed->Surrealdb_ManagedLiveSubscription.fromSubscription->Option.isSome,
        managed->Surrealdb_UnmanagedLiveSubscription.fromSubscription->Option.isSome,
        managed->Surrealdb_LiveSubscription.isManaged,
        unmanaged->Surrealdb_ManagedLiveSubscription.fromSubscription->Option.isSome,
        unmanaged->Surrealdb_UnmanagedLiveSubscription.fromSubscription->Option.isSome,
        unmanaged->Surrealdb_LiveSubscription.isManaged,
      ))->Vitest.Expect.toEqual((true, false, true, false, true, false))

      let managedMessages = Surrealdb_ChannelIterator.make()
      let unmanagedMessages = Surrealdb_ChannelIterator.make()
      let unsubscribeManaged =
        managed->Surrealdb_LiveSubscription.subscribe(message =>
          managedMessages->Surrealdb_ChannelIterator.submit(message)
        )
      let unsubscribeUnmanaged =
        unmanaged->Surrealdb_LiveSubscription.subscribe(message =>
          unmanagedMessages->Surrealdb_ChannelIterator.submit(message)
        )

      ignore(
        await db
        ->Surrealdb_Surreal.asQueryable
        ->Surrealdb_Create.recordOn(tableName, "alpha")
        ->Surrealdb_Create.content(
            Dict.fromArray([
              ("value", Surrealdb_JsValue.int(2)),
              ("label", Surrealdb_JsValue.string("alpha")),
            ]),
          )
        ->Surrealdb_Create.resolve,
      )

      let managedObserved = await managedMessages->Surrealdb_ChannelIterator.next
      let unmanagedObserved = await unmanagedMessages->Surrealdb_ChannelIterator.next
      unsubscribeManaged()
      unsubscribeUnmanaged()
      managedMessages->Surrealdb_ChannelIterator.cancel
      unmanagedMessages->Surrealdb_ChannelIterator.cancel

      t->Vitest.expect((
        managedObserved->Surrealdb_ChannelIterator.value->Option.map(liveMessageSummary),
        unmanagedObserved->Surrealdb_ChannelIterator.value->Option.map(liveMessageSummary),
      ))->Vitest.Expect.toEqual((
        Some((
          managed->Surrealdb_LiveSubscription.id->Surrealdb_Uuid.toString,
          "CREATE",
          "widgets:alpha",
          (Some("2"), Some("alpha")),
        )),
        Some((
          unmanaged->Surrealdb_LiveSubscription.id->Surrealdb_Uuid.toString,
          "CREATE",
          "widgets:alpha",
          (Some("2"), Some("alpha")),
        )),
      ))

      await killIgnore(managed)
      await killIgnore(unmanaged)
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
