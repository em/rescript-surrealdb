import assert from "node:assert/strict"
import { spawn } from "node:child_process"
import { mkdtemp, mkdir, readFile, rm, unlink, writeFile } from "node:fs/promises"
import os from "node:os"
import path from "node:path"

const repoRoot = path.resolve(new URL("..", import.meta.url).pathname)
const tempRoot = await mkdtemp(path.join(os.tmpdir(), "rescript-surrealdb-consumer-"))

function run(command, args, options = {}) {
  return new Promise((resolve, reject) => {
    const child = spawn(command, args, {
      cwd: options.cwd ?? repoRoot,
      env: { ...process.env, ...(options.env ?? {}) },
      stdio: ["ignore", "pipe", "pipe"],
    })

    let stdout = ""
    let stderr = ""

    child.stdout.on("data", chunk => {
      const text = chunk.toString()
      stdout += text
      process.stdout.write(text)
    })

    child.stderr.on("data", chunk => {
      const text = chunk.toString()
      stderr += text
      process.stderr.write(text)
    })

    child.on("error", reject)

    child.on("close", code => {
      if (code === 0) {
        resolve({ stdout, stderr })
      } else {
        reject(new Error(`${command} ${args.join(" ")} failed with code ${code}\n${stdout}${stderr}`))
      }
    })
  })
}

function consumerPackageJson(tarballPath) {
  return JSON.stringify(
    {
      name: "rescript-surrealdb-packed-consumer-proof",
      private: true,
      type: "module",
      scripts: {
        build: "rescript build",
        check: "node ./runtime-check.mjs",
      },
      dependencies: {
        "@rescript/runtime": "12.2.0",
        "rescript-surrealdb": `file:${tarballPath}`,
        "rescript-webapi": "^0.10.0",
        surrealdb: "^2.0.3",
      },
      devDependencies: {
        rescript: "12.2.0",
      },
    },
    null,
    2,
  )
}

const consumerRescriptJson = JSON.stringify(
  {
    name: "rescript-surrealdb-packed-consumer-proof",
    namespace: false,
    sources: [{ dir: "src", subdirs: true }],
    "package-specs": {
      module: "esmodule",
      "in-source": true,
    },
    suffix: ".mjs",
    dependencies: ["rescript-surrealdb", "rescript-webapi"],
    warnings: { error: "+8" },
  },
  null,
  2,
)

const consumerSource = `module Api = Surrealdb.Api
module Connection = Surrealdb.Connection
module Query = Surrealdb.Query
module Support = Surrealdb.Support
module Values = Surrealdb.Values

external toUnknown: 'a => unknown = "%identity"

@module("./ConsumerFixtures.mjs")
external recordIdWithFunction: unit => Values.RecordId.t = "recordIdWithFunction"

@module("./ConsumerFixtures.mjs")
external recordIdWithDateTime: unit => Values.RecordId.t = "recordIdWithDateTime"

let db = Connection.RemoteEngines.create()->Connection.Surreal.withRemoteEngines

let typedQueryJson: Query.Query.t<array<JSON.t>> =
  db->Query.Query.text("RETURN $item", ~bindings=Support.JsValue.bindings([("item", Support.JsValue.String("alpha"))]), ())->Query.Query.json

let typedSelectJson: Query.Select.t<JSON.t> =
  db->Query.Select.table("widgets")->Query.Select.json

let typedAuthJson: Connection.Auth.t<JSON.t> =
  db->Connection.Surreal.asQueryable->Connection.Queryable.auth->Connection.Auth.json

let typedApiResponseJson = (client: Api.Client.t): Api.Promise.t<Api.Promise.responseMode, Api.Promise.jsonFormat> =>
  client->Api.Client.get_("/health")->Api.Promise.json

let typedApiBodyJson = (client: Api.Client.t): Api.Promise.t<Api.Promise.bodyMode, Api.Promise.jsonFormat> =>
  client->Api.Client.get_("/health")->Api.Promise.value->Api.Promise.json

let typedRange =
  Values.Range.make(
    ~begin=Values.RangeBound.included(Values.RangeBound.Int(1)),
    ~end=Values.RangeBound.excluded(
      Values.RangeBound.Object(
        Dict.fromArray([
          ("slug", Values.RangeBound.String("demo")),
        ]),
      ),
    ),
    (),
  )

let supportedRecordId =
  Values.RecordId.makeWithIdValue(
    "widgets",
    Values.RecordId.ObjectId(
      Dict.fromArray([
        (
          "parts",
          Values.RecordId.Array([
            Values.RecordId.String("alpha"),
            Values.RecordId.BigInt(7n),
          ]),
        ),
      ]),
    ),
  )

let rec componentText = component =>
  switch component {
  | Values.RecordId.Undefined => "undefined"
  | Null => "null"
  | Bool(value) => value ? "true" : "false"
  | Int(value) => value->Int.toString
  | Float(value) => value->Float.toString
  | String(value) => value
  | BigInt(value) => \`\${value->BigInt.toString}n\`
  | ValueClass(value) => value->Values.ValueClass.toString
  | Array(items) => "[" ++ items->Array.map(componentText)->Array.join(", ") ++ "]"
  | Object(entries) =>
    "{" ++ entries->Dict.toArray->Array.map(((key, item)) => key ++ ":" ++ item->componentText)->Array.join(", ") ++ "}"
  }

let idValueText = value =>
  switch value {
  | Values.RecordId.StringId(raw) => raw
  | NumberId(raw) => raw->Float.toString
  | UuidId(raw) => raw->Values.Uuid.toString
  | BigIntId(raw) => \`\${raw->BigInt.toString}n\`
  | ArrayId(items) => "[" ++ items->Array.map(componentText)->Array.join(", ") ++ "]"
  | ObjectId(entries) =>
    "{" ++ entries->Dict.toArray->Array.map(((key, item)) => key ++ ":" ++ item->componentText)->Array.join(", ") ++ "}"
  }

let queryAndApiSummary = () => (
  typedQueryJson->Query.Query.inner->Query.Bound.query,
  typedSelectJson->Query.Select.compile->Query.Bound.query,
  typedAuthJson->Connection.Auth.compile->Query.Bound.query,
)

let rangeSummary = () => (
  typedRange->Values.Range.toString,
  typedRange
  ->Values.Range.begin
  ->Option.map(bound => bound->Values.RangeBound.value->Values.BoundValue.toText)
  ->Option.getOr(""),
  typedRange
  ->Values.Range.end_
  ->Option.map(bound => bound->Values.RangeBound.value->Values.BoundValue.toJSON->JSON.stringifyAny->Option.getOr(""))
  ->Option.getOr(""),
)

let recordIdSummary = () => (
  supportedRecordId->Values.RecordId.idValue->Option.map(idValueText)->Option.getOr("none"),
  recordIdWithDateTime()->Values.RecordId.idValue->Option.map(idValueText)->Option.getOr("none"),
  recordIdWithFunction()->Values.RecordId.idValue->Option.isSome,
)

let codecSummary = () => {
  let valueCodec = Values.CborCodec.default()->Values.ValueCodec.fromCborCodec
  let valueBytes = valueCodec->Values.ValueCodec.encode("alpha"->toUnknown)
  let valueUnknown =
    valueCodec->Values.ValueCodec.decodeUnknown(valueBytes)->Values.Value.fromUnknown->Values.Value.toText
  let valueChecked =
    switch valueCodec->Values.ValueCodec.decodeWith(valueBytes, raw =>
      switch raw->Values.Value.fromUnknown {
      | String(value) => Some(value)
      | _ => None
      }
    ) {
    | Ok(value) => value
    | Error(_) => "<value-decode-error>"
    }
  let cborCodec = Values.CborCodec.default()
  let cborBytes = cborCodec->Values.CborCodec.encode("beta"->toUnknown)
  let cborUnknown =
    cborCodec->Values.CborCodec.decodeUnknown(cborBytes)->Values.Value.fromUnknown->Values.Value.toText
  let cborChecked =
    switch cborCodec->Values.CborCodec.decodeWith(cborBytes, raw =>
      switch raw->Values.Value.fromUnknown {
      | String(value) => Some(value)
      | _ => None
      }
    ) {
    | Ok(value) => value
    | Error(_) => "<cbor-decode-error>"
    }

  (
    valueUnknown,
    valueChecked,
    valueBytes->Values.ValueCodec.encodedLength,
    cborUnknown,
    cborChecked,
    cborBytes->Values.ValueCodec.byteLength,
  )
}
`

const consumerFixtures = `import { DateTime, RecordId } from "surrealdb"

export function recordIdWithFunction() {
  return new RecordId("widgets", { bad: () => "x" })
}

export function recordIdWithDateTime() {
  return new RecordId("widgets", { when: new DateTime("2026-04-23T00:00:00.000Z") })
}
`

const runtimeCheck = `import assert from "node:assert/strict"
import * as Consumer from "./src/Consumer.mjs"

const queryAndApi = Consumer.queryAndApiSummary()
assert.equal(queryAndApi[0], "RETURN $item")
assert.ok(queryAndApi[1].startsWith("SELECT * FROM $bind__"))
assert.equal(queryAndApi[2], "SELECT * FROM ONLY $auth")

const rangeSummary = Consumer.rangeSummary()
assert.ok(rangeSummary[0].startsWith("1.."))
assert.equal(rangeSummary[1], "1")
assert.equal(rangeSummary[2], "{\\"slug\\":\\"demo\\"}")

const recordIdSummary = Consumer.recordIdSummary()
assert.equal(recordIdSummary[0], "{parts:[alpha, 7n]}")
assert.equal(recordIdSummary[1], "{when:2026-04-23T00:00:00.000Z}")
assert.equal(recordIdSummary[2], false)

const codecSummary = Consumer.codecSummary()
assert.equal(codecSummary[0], "alpha")
assert.equal(codecSummary[1], "alpha")
assert.ok(codecSummary[2] > 0)
assert.equal(codecSummary[3], "beta")
assert.equal(codecSummary[4], "beta")
assert.ok(codecSummary[5] > 0)
`

let tarballPath = ""

try {
  const pack = await run("npm", ["pack", "--json"])
  const [{ filename }] = JSON.parse(pack.stdout)
  tarballPath = path.join(repoRoot, filename)

  const consumerDir = path.join(tempRoot, "consumer")
  const consumerSrc = path.join(consumerDir, "src")

  await mkdir(consumerSrc, { recursive: true })
  await writeFile(path.join(consumerDir, "package.json"), consumerPackageJson(tarballPath))
  await writeFile(path.join(consumerDir, "rescript.json"), consumerRescriptJson)
  await writeFile(path.join(consumerSrc, "Consumer.res"), consumerSource)
  await writeFile(path.join(consumerSrc, "ConsumerFixtures.mjs"), consumerFixtures)
  await writeFile(path.join(consumerDir, "runtime-check.mjs"), runtimeCheck)

  await run("npm", ["install"], { cwd: consumerDir })
  await run("npx", ["rescript", "build"], { cwd: consumerDir })
  await run("node", ["./runtime-check.mjs"], { cwd: consumerDir })

  const compiledConsumer = await readFile(path.join(consumerSrc, "Consumer.mjs"), "utf8")
  assert.ok(compiledConsumer.includes("rescript-surrealdb"))
} finally {
  if (tarballPath) {
    await unlink(tarballPath).catch(() => {})
  }
  await rm(tempRoot, { recursive: true, force: true })
}
