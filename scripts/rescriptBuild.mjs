import { spawn } from "node:child_process"
import { rm } from "node:fs/promises"

function run(command, args) {
  return new Promise(resolve => {
    const child = spawn(command, args, { stdio: ["inherit", "pipe", "pipe"] })
    let combined = ""

    child.stdout.on("data", chunk => {
      const text = chunk.toString()
      combined += text
      process.stdout.write(text)
    })

    child.stderr.on("data", chunk => {
      const text = chunk.toString()
      combined += text
      process.stderr.write(text)
    })

    child.on("close", code => {
      resolve({ code: code ?? 1, combined })
    })

    child.on("error", error => {
      const text = `${error.message}\n`
      combined += text
      process.stderr.write(text)
      resolve({ code: 1, combined })
    })
  })
}

function isCopyPanic(output) {
  return output.includes("copying source file failed") || output.includes("Operation not permitted")
}

async function clearGeneratedArtifacts() {
  await rm(new URL("../lib/bs", import.meta.url), { recursive: true, force: true })
  await rm(new URL("../lib/ocaml", import.meta.url), { recursive: true, force: true })
}

const first = await run("rescript", ["build"])

if (first.code === 0) {
  process.exit(0)
}

if (!isCopyPanic(first.combined)) {
  process.exit(first.code)
}

process.stderr.write("ReScript hit the source-copy panic. Clearing generated artifacts and retrying once.\n")
await clearGeneratedArtifacts()

const retry = await run("rescript", ["build"])
process.exit(retry.code)
