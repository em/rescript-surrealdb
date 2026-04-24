function stringEnv(name, fallback) {
  const value = process.env[name]
  return value && value.length > 0 ? value : fallback
}

export default async function globalSetup(project) {
  const externalEndpoint = stringEnv("SURREALDB_TEST_ENDPOINT", "ws://127.0.0.1:8787/rpc")
  process.env.SURREALDB_TEST_ENDPOINT = externalEndpoint
  process.env.SURREALDB_TEST_NAMESPACE = stringEnv("SURREALDB_TEST_NAMESPACE", "test")
  process.env.SURREALDB_TEST_DATABASE = stringEnv("SURREALDB_TEST_DATABASE", "rescript_surrealdb")
  process.env.SURREALDB_TEST_USERNAME = stringEnv("SURREALDB_TEST_USERNAME", "root")
  process.env.SURREALDB_TEST_PASSWORD = stringEnv("SURREALDB_TEST_PASSWORD", "root")
}
