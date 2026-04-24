import {spawnSync} from "node:child_process"

const commands = [
  {
    command: process.platform === "win32" ? "npx.cmd" : "npx",
    args: ["changeset", "version"],
  },
  {
    command: process.platform === "win32" ? "npm.cmd" : "npm",
    args: ["install", "--package-lock-only"],
  },
]

for (const {command, args} of commands) {
  const result = spawnSync(command, args, {stdio: "inherit"})
  if (result.error) {
    console.error(result.error.message)
    process.exit(1)
  }

  if ((result.status ?? 1) !== 0) {
    process.exit(result.status ?? 1)
  }
}
