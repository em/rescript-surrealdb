import { randomUUID } from "node:crypto"
import { accessSync, constants } from "node:fs"
import { createServer } from "node:net"
import { mkdtemp, rm } from "node:fs/promises"
import { tmpdir } from "node:os"
import { join } from "node:path"
import { spawn } from "node:child_process"
import { setTimeout as delay } from "node:timers/promises"

function stringEnv(name, fallback) {
  const value = process.env[name]
  return value && value.length > 0 ? value : fallback
}

function slug(value) {
  return value.replace(/[^a-zA-Z0-9]+/g, "_")
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
  const explicitBin = process.env.SURREALDB_TEST_SERVER_BIN
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

async function reservePort() {
  return await new Promise((resolve, reject) => {
    const server = createServer()
    server.on("error", reject)
    server.listen(0, "127.0.0.1", () => {
      const address = server.address()
      if (!address || typeof address === "string") {
        server.close(() => reject(new Error("Failed to reserve test port")))
        return
      }

      const { port } = address
      server.close(error => {
        if (error) {
          reject(error)
          return
        }

        resolve(port)
      })
    })
  })
}

async function stopProcess(processRef) {
  if (processRef.exitCode !== null || processRef.signalCode !== null) {
    return
  }

  processRef.kill("SIGTERM")

  for (let attempt = 0; attempt < 20; attempt += 1) {
    if (processRef.exitCode !== null || processRef.signalCode !== null) {
      return
    }
    await delay(100)
  }

  processRef.kill("SIGKILL")
}

export async function startSurrealTestServer() {
  const runId = slug(randomUUID())
  const port = stringEnv("SURREALDB_TEST_PORT", `${await reservePort()}`)
  const username = stringEnv("SURREALDB_TEST_USERNAME", "root")
  const password = stringEnv("SURREALDB_TEST_PASSWORD", "root")
  const namespace = stringEnv("SURREALDB_TEST_NAMESPACE", `test_${runId}`)
  const database = stringEnv("SURREALDB_TEST_DATABASE", `rescript_surrealdb_${runId}`)
  const bind = `127.0.0.1:${port}`
  const storage = stringEnv("SURREALDB_TEST_STORAGE", "memory")
  const tempDir = storage === "memory" ? null : await mkdtemp(join(tmpdir(), "rescript-surrealdb-"))
  const resolvedStorage = storage === "memory" ? "memory" : `rocksdb://${join(tempDir, "test.db")}`
  const surrealArgs = [
    "start",
    "--user",
    username,
    "--pass",
    password,
    "--bind",
    bind,
    "--log",
    stringEnv("SURREALDB_TEST_LOG_LEVEL", "error"),
    "--no-banner",
    resolvedStorage,
  ]
  const envCommand = process.env.SURREALDB_TEST_SERVER_CMD
  const serverBin = resolveServerBin()
  const processRef =
    envCommand && envCommand.length > 0
      ? spawn("/bin/sh", ["-lc", `${envCommand} ${surrealArgs.join(" ")}`], { stdio: "ignore" })
      : spawn(serverBin, surrealArgs, { stdio: "ignore" })
  const commandText =
    envCommand && envCommand.length > 0
      ? `${envCommand} ${surrealArgs.join(" ")}`
      : [serverBin, ...surrealArgs].join(" ")
  let spawnError = null
  processRef.on("error", error => {
    spawnError = error
  })

  try {
    const waitDeadline = Date.now() + 30000

    while (Date.now() < waitDeadline) {
      if (spawnError) {
        throw spawnError
      }

      if (processRef.exitCode !== null) {
        throw new Error(
          `SurrealDB test server exited before becoming ready. Command: ${commandText}. Exit code: ${processRef.exitCode}`,
        )
      }

      try {
        const response = await fetch(`http://127.0.0.1:${port}/version`)
        if (response.ok) {
          break
        }
      } catch (_error) {
      }

      await delay(250)
    }

    if (spawnError) {
      throw spawnError
    }

    const response = await fetch(`http://127.0.0.1:${port}/version`).catch(() => null)
    if (!response || !response.ok) {
      throw new Error(`Timed out waiting for isolated SurrealDB at http://127.0.0.1:${port}`)
    }
  } catch (error) {
    await stopProcess(processRef)
    if (tempDir) {
      await rm(tempDir, { recursive: true, force: true })
    }

    if (error && (error.code === "ENOENT" || error.code === "EACCES")) {
      throw new Error(
        `Failed to start isolated SurrealDB test server because \`${envCommand && envCommand.length > 0 ? envCommand : serverBin}\` was unavailable or not executable. Install the SurrealDB server binary, put it on PATH, or set SURREALDB_TEST_SERVER_BIN / SURREALDB_TEST_SERVER_CMD.`,
      )
    }

    throw error
  }

  return {
    endpoint: `ws://127.0.0.1:${port}/rpc`,
    namespace,
    database,
    username,
    password,
    stop: async () => {
      await stopProcess(processRef)
      if (tempDir) {
        await rm(tempDir, { recursive: true, force: true })
      }
    },
  }
}
