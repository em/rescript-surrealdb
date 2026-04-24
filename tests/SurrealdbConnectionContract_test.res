module Support = SurrealdbSessionTestSupport

let fileText = Support.fileText

Vitest.describe("SurrealDB connection contract", () => {
  Vitest.test("health is absent from the unsupported ws/rpc public binding surface", t => {
    let resiTexts = [
      ["src", "connection", "Surrealdb_Surreal.resi"],
      ["src", "connection", "Surrealdb_RpcEngine.resi"],
    ]->Array.map(fileText)

    let jsTexts = [
      ["src", "connection", "Surrealdb_Surreal.mjs"],
      ["src", "connection", "Surrealdb_RpcEngine.mjs"],
    ]->Array.map(fileText)

    t->Vitest.expect((
      resiTexts->Array.every(text => !(text->String.includes("let health:"))),
      jsTexts->Array.every(text => !(text->String.includes("function health("))),
    ))
    ->Vitest.Expect.toEqual((true, true))
  })
})
