open TestRuntime

let payloadToString = payload =>
  payload
  ->Array.map(Surrealdb_Value.toJSON)
  ->JSON.Encode.array
  ->JSON.stringifyAny
  ->Option.getOr("")

describe("SurrealDB stream utilities", () => {
  testAsync("ChannelIterator yields submitted values", async () => {
    let iterator = Surrealdb_ChannelIterator.make()
    iterator->Surrealdb_ChannelIterator.submit("alpha")
    let result = await iterator->Surrealdb_ChannelIterator.next
    result->Surrealdb_ChannelIterator.done->Expect.expect->Expect.toBe(false)
    result->Surrealdb_ChannelIterator.value->Option.getOr("")->Expect.expect->Expect.toBe("alpha")
    iterator->Surrealdb_ChannelIterator.cancel
  })

  testAsync("Publisher subscribes and resolves first matching event", async () => {
    let publisher = Surrealdb_Publisher.make()
    let seen = ref("")
    let unsubscribe = publisher->Surrealdb_Publisher.subscribe("tick", payload => {
      seen.contents = payload->payloadToString
    })
    let first = publisher->Surrealdb_Publisher.subscribeFirst(["tick"])
    publisher->Surrealdb_Publisher.publish("tick", [Surrealdb_JsValue.string("alpha"), Surrealdb_JsValue.int(2)])
    let resolvedPayload = await first
    unsubscribe()
    seen.contents->Expect.expect->Expect.toBe("[\"alpha\",2]")
    resolvedPayload->payloadToString->Expect.expect->Expect.toBe("[\"alpha\",2]")
  })
})
