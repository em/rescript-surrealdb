import { startSurrealTestServer } from "./surrealServer.mjs"

function stringEnv(name, fallback) {
  const value = process.env[name]
  return value && value.length > 0 ? value : fallback
}

export default async function globalSetup(project) {
  const externalEndpoint = process.env.SURREALDB_TEST_ENDPOINT

  if (externalEndpoint) {
    project.provide("surrealEndpoint", externalEndpoint)
    project.provide("surrealNamespace", stringEnv("SURREALDB_TEST_NAMESPACE", "test"))
    project.provide("surrealDatabase", stringEnv("SURREALDB_TEST_DATABASE", "rescript_surrealdb"))
    project.provide("surrealUsername", stringEnv("SURREALDB_TEST_USERNAME", "root"))
    project.provide("surrealPassword", stringEnv("SURREALDB_TEST_PASSWORD", "root"))
    return
  }

  const server = await startSurrealTestServer()

  project.provide("surrealEndpoint", server.endpoint)
  project.provide("surrealNamespace", server.namespace)
  project.provide("surrealDatabase", server.database)
  project.provide("surrealUsername", server.username)
  project.provide("surrealPassword", server.password)

  return async () => {
    await server.stop()
  }
}
