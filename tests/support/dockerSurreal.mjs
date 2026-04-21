import { randomUUID } from "node:crypto"
import { execFile } from "node:child_process"
import { createServer } from "node:net"
import { promisify } from "node:util"
import { setTimeout as delay } from "node:timers/promises"

const execFileAsync = promisify(execFile)

function stringEnv(name, fallback) {
  const value = process.env[name]
  return value && value.length > 0 ? value : fallback
}

function slug(value) {
  return value.replace(/[^a-zA-Z0-9]+/g, "_")
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

async function waitForServer(httpBaseUrl) {
  const deadline = Date.now() + 30000

  while (Date.now() < deadline) {
    try {
      const response = await fetch(`${httpBaseUrl}/version`)
      if (response.ok) {
        return
      }
    } catch (_error) {
    }

    await delay(250)
  }

  throw new Error(`Timed out waiting for isolated SurrealDB at ${httpBaseUrl}`)
}

async function stopContainer(containerName) {
  try {
    await execFileAsync("docker", ["stop", containerName])
  } catch (_error) {
  }
}

export async function startDockerSurreal() {
  const runId = slug(randomUUID())
  const port = stringEnv("SURREALDB_TEST_PORT", `${await reservePort()}`)
  const image = stringEnv("SURREALDB_TEST_IMAGE", "surrealdb/surrealdb:latest")
  const username = stringEnv("SURREALDB_TEST_USERNAME", "root")
  const password = stringEnv("SURREALDB_TEST_PASSWORD", "root")
  const namespace = stringEnv("SURREALDB_TEST_NAMESPACE", `test_${runId}`)
  const database = stringEnv("SURREALDB_TEST_DATABASE", `rescript_surrealdb_${runId}`)
  const containerName = `rescript-surrealdb-vitest-${runId}`

  try {
    await execFileAsync("docker", [
      "run",
      "--detach",
      "--rm",
      "--pull=missing",
      "--name",
      containerName,
      "--publish",
      `127.0.0.1:${port}:8000`,
      image,
      "start",
      "--log",
      "error",
      "--user",
      username,
      "--pass",
      password,
      "memory",
    ])
  } catch (error) {
    throw new Error(
      `Failed to start isolated SurrealDB Docker container. Set SURREALDB_TEST_ENDPOINT explicitly for a disposable test instance or make Docker available. Original error: ${error instanceof Error ? error.message : String(error)}`,
    )
  }

  const httpBaseUrl = `http://127.0.0.1:${port}`

  try {
    await waitForServer(httpBaseUrl)
  } catch (error) {
    await stopContainer(containerName)
    throw error
  }

  return {
    endpoint: `ws://127.0.0.1:${port}/rpc`,
    namespace,
    database,
    username,
    password,
    stop: async () => {
      await stopContainer(containerName)
    },
  }
}
