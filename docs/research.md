# Research

## Official sources

- `https://surrealdb.com/docs/sdk/javascript`
  - The JavaScript SDK is the public source of truth for client construction, query building, sessions, live queries, and typed value classes.
- `https://surrealdb.com/docs/sdk/javascript/core/data-types`
  - The SDK exposes first-class value classes such as `RecordId`, `DateTime`, `Duration`, `Decimal`, `Table`, `Uuid`, ranges, and geometry types. The ReScript bindings must preserve those runtime classes instead of flattening them into JSON.
- `https://vitest.dev/config/`
  - Vitest supports a `globalSetup` hook, which is the right place to provision the live SurrealDB test environment once per run.
- `https://vitest.dev/guide/`
  - Vitest exports runtime functions such as `describe`, `test`, `expect`, and `inject` that can be bound directly from ReScript.
- `https://rescript-lang.org/docs/manual/build-configuration`
  - `rescript.json` controls package layout, source directories, output module format, and package-wide compiler settings.
- `https://rescript-lang.org/blog/release-12-0-0`
  - ReScript 12 moved the runtime to `@rescript/runtime`, replacing the older `@rescript/std` package.
- `https://rescript-lang.org/docs/manual/migrate-to-v12/`
  - ReScript 12 packages should remove `@rescript/std`; the runtime dependency is now `@rescript/runtime`.

## Installed SDK inspection

- `node -e "const p=require('./node_modules/surrealdb/package.json'); console.log(JSON.stringify({name:p.name,version:p.version,exports:p.exports}, null, 2))"`
  - The installed SDK version is `2.0.3`, with the public package export rooted at `dist/surrealdb.d.ts`, `dist/surrealdb.mjs`, and `dist/surrealdb.server.mjs`.
- `rg -n "export declare class|export declare function" ./node_modules/surrealdb/dist/surrealdb.d.ts`
  - The installed public surface includes bound-query helpers, value classes, query/session/client types, live query types, API types, engines, diagnostics, feature flags, and typed error classes.

## Local runtime constraints

- `node --version`
  - The local Node runtime is `v24.8.0`.
- `docker --version`
  - Docker is available locally, which makes it possible to run live Vitest coverage against a real local SurrealDB server container.
- `surreal version`
  - The standalone `surreal` binary is not installed in this environment, so the live suite cannot depend on that executable being present.
