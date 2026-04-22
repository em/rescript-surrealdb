import {spawnSync} from "node:child_process"

const errors = []

if (process.env.GITHUB_ACTIONS !== "true") {
  errors.push("release:ci may only run inside GitHub Actions.")
}

if (!process.env.ACTIONS_ID_TOKEN_REQUEST_URL) {
  errors.push("Missing ACTIONS_ID_TOKEN_REQUEST_URL for trusted publishing provenance.")
}

if (!process.env.ACTIONS_ID_TOKEN_REQUEST_TOKEN) {
  errors.push("Missing ACTIONS_ID_TOKEN_REQUEST_TOKEN for trusted publishing provenance.")
}

if (errors.length > 0) {
  console.error(errors.join("\n"))
  process.exit(1)
}

const npmCommand = process.platform === "win32" ? "npm.cmd" : "npm"
const result = spawnSync(npmCommand, ["publish", "--access", "public", "--provenance"], {
  stdio: "inherit",
})

if (result.error) {
  console.error(result.error.message)
  process.exit(1)
}

process.exit(result.status ?? 1)
