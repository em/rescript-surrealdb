import { spawn } from "node:child_process"
import { accessSync, constants } from "node:fs"

function stringEnv(name, fallback) {
  const value = process.env[name]
  return value && value.length > 0 ? value : fallback
}

function canExecute(path) {
  try {
    accessSync(path, constants.X_OK)
    return true
  } catch (_error) {
    return false
  }
}

function resolveServerBin() {
  const explicitBin = process.env.SURREALDB_SERVER_BIN || process.env.SURREALDB_TEST_SERVER_BIN
  if (explicitBin && explicitBin.length > 0) {
    return explicitBin
  }

  const candidates = [
    "/home/m/.surrealdb/surreal",
    `${process.env.HOME || ""}/.surrealdb/surreal`,
    "/usr/local/bin/surreal",
    "/usr/bin/surreal",
    "surreal",
  ]

  for (const candidate of candidates) {
    if (candidate === "surreal" || canExecute(candidate)) {
      return candidate
    }
  }

  return "surreal"
}

const serverBin = resolveServerBin()
const bind = stringEnv("SURREALDB_BIND", "127.0.0.1:8000")
const username = stringEnv("SURREALDB_USER", "root")
const password = stringEnv("SURREALDB_PASS", "root")
const logLevel = stringEnv("SURREALDB_LOG_LEVEL", "error")
const storage = stringEnv("SURREALDB_STORAGE", "memory")

const args = ["start", "--user", username, "--pass", password, "--bind", bind, "--log", logLevel, "--no-banner", storage]
const processRef = spawn(serverBin, args, { stdio: "inherit" })

processRef.on("error", error => {
  console.error(
    `Failed to start SurrealDB with \`${serverBin}\`. Install the SurrealDB server binary, put it on PATH, or set SURREALDB_SERVER_BIN.`,
  )
  console.error(error.message)
  process.exit(1)
})

processRef.on("exit", code => {
  process.exit(code ?? 0)
})
