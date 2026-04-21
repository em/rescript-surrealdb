// tests/SurrealdbTestContext.res — live-test runtime config accessors.
// Concern: expose the Vitest-provided SurrealDB test configuration to ReScript.

let endpoint = () => TestRuntime.injectString("surrealEndpoint")
let namespace = () => TestRuntime.injectString("surrealNamespace")
let database = () => TestRuntime.injectString("surrealDatabase")
let username = () => TestRuntime.injectString("surrealUsername")
let password = () => TestRuntime.injectString("surrealPassword")
