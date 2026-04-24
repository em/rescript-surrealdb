// tests/SurrealdbTestContext.res — live-test runtime config accessors.
// Concern: expose the Vitest-provided SurrealDB test configuration to ReScript.
let requiredEnv = name =>
  switch NodeJs.Process.process->NodeJs.Process.env->Dict.get(name) {
  | Some(value) => value
  | None => failwith(`Missing ${name}`)
  }

let endpoint = () => requiredEnv("SURREALDB_TEST_ENDPOINT")
let namespace = () => requiredEnv("SURREALDB_TEST_NAMESPACE")
let database = () => requiredEnv("SURREALDB_TEST_DATABASE")
let username = () => requiredEnv("SURREALDB_TEST_USERNAME")
let password = () => requiredEnv("SURREALDB_TEST_PASSWORD")
