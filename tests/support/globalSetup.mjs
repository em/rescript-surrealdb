function stringEnv(name, fallback) {
  const value = process.env[name]
  return value && value.length > 0 ? value : fallback
}

export default async function globalSetup(project) {
  const externalEndpoint = process.env.SURREALDB_TEST_ENDPOINT

  if (!externalEndpoint) {
    throw new Error(
      "Set SURREALDB_TEST_ENDPOINT, SURREALDB_TEST_NAMESPACE, SURREALDB_TEST_DATABASE, SURREALDB_TEST_USERNAME, and SURREALDB_TEST_PASSWORD explicitly. The fake local auto-start path was deleted.",
    )
  }

  process.env.SURREALDB_TEST_ENDPOINT = externalEndpoint
  process.env.SURREALDB_TEST_NAMESPACE = stringEnv("SURREALDB_TEST_NAMESPACE", "test")
  process.env.SURREALDB_TEST_DATABASE = stringEnv("SURREALDB_TEST_DATABASE", "rescript_surrealdb")
  process.env.SURREALDB_TEST_USERNAME = stringEnv("SURREALDB_TEST_USERNAME", "root")
  process.env.SURREALDB_TEST_PASSWORD = stringEnv("SURREALDB_TEST_PASSWORD", "root")
}
