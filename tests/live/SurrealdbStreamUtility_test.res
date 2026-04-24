let payloadToString = payload =>
  payload
  ->Array.map(Surrealdb_Value.toJSON)
  ->JSON.Encode.array
  ->JSON.stringifyAny
  ->Option.getOr("")

Vitest.describe("SurrealDB stream utilities", () => {
  Vitest.testAsync("ChannelIterator yields submitted values", async t => {
    let iterator = Surrealdb_ChannelIterator.make()
    iterator->Surrealdb_ChannelIterator.submit("alpha")
    let result = await iterator->Surrealdb_ChannelIterator.next
    t->Vitest.expect(result->Surrealdb_ChannelIterator.done)->Vitest.Expect.toBe(false)
    t->Vitest.expect(result->Surrealdb_ChannelIterator.value->Option.getOr(""))->Vitest.Expect.toBe("alpha")
    iterator->Surrealdb_ChannelIterator.cancel
  })

  Vitest.testAsync("Publisher subscribes and resolves first matching event", async t => {
    let publisher = Surrealdb_Publisher.make()
    let seen = ref("")
    let unsubscribe = publisher->Surrealdb_Publisher.subscribe("tick", payload => {
      seen.contents = payload->payloadToString
    })
    let first = publisher->Surrealdb_Publisher.subscribeFirst(["tick"])
    publisher->Surrealdb_Publisher.publish("tick", [Surrealdb_JsValue.string("alpha"), Surrealdb_JsValue.int(2)])
    let resolvedPayload = await first
    unsubscribe()
    t->Vitest.expect(seen.contents)->Vitest.Expect.toBe("[\"alpha\",2]")
    t->Vitest.expect(resolvedPayload->payloadToString)->Vitest.Expect.toBe("[\"alpha\",2]")
  })
})
