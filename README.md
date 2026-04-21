# rescript-surrealdb

`rescript-surrealdb` is a reusable ReScript binding package for the public SurrealDB JavaScript SDK.

## Goals

- Bind the actual public `surrealdb` SDK surface.
- Preserve typed SurrealDB runtime classes as opaque ReScript types.
- Keep the package generic and reusable outside any single app.
- Verify the binding surface with Vitest plus live SDK execution against a local SurrealDB instance.

## Install

```sh
npm install surrealdb rescript-surrealdb
```

`surrealdb` is a peer dependency of the binding package.

## Package shape

- `src/Surrealdb.res` exposes the top-level export map.
- `src/api/` contains HTTP API bindings.
- `src/connection/` contains client, session, transaction, engine, and feature bindings.
- `src/errors/` contains typed SDK error bindings.
- `src/live/` contains live query, frame, and subscription bindings.
- `src/query/` contains query builders, CRUD, import/export, and queryable surfaces.
- `src/support/` contains internal binding support modules.
- `src/value/` contains typed SurrealDB value classes and value utilities.

## Development

```sh
npm install
npm run build
npm test
npm run test:live
```

`npm test` runs the non-live suite and does not attach to any server.

`npm run test:live` runs the live connection suite. It uses `SURREALDB_TEST_ENDPOINT` only when you explicitly provide a disposable test instance. Without that env var, it starts its own isolated local `surreal start ...` process, allocates a fresh namespace and database for the run, and tears the process down afterward. It does not attach to arbitrary local SurrealDB servers.

If `surreal` is not on `PATH`, set one of:

```sh
SURREALDB_TEST_SERVER_BIN=/absolute/path/to/surreal npm run test:live
SURREALDB_TEST_SERVER_CMD='surreal' npm run test:live
```

The launcher also auto-detects the common local install path `/home/m/.surrealdb/surreal` when present.

## Release Management

- Versioning is managed with Changesets.
- Run `npm run changeset` for any user-facing package change.
- The `release.yml` workflow opens or updates the release PR on `main`.
- Merging that release PR runs `npm run release` in GitHub Actions and publishes to npm.
- The repo needs a GitHub Actions secret named `NPM_TOKEN` with publish rights for `rescript-surrealdb`.

## Docs

- [`docs/research.md`](./docs/research.md)
- [`docs/design.md`](./docs/design.md)
- [`TYPE_FIDELITY.md`](./TYPE_FIDELITY.md)

## Examples

- [`examples/Example_Connect.res`](./examples/Example_Connect.res)
- [`examples/Example_Query.res`](./examples/Example_Query.res)
- [`examples/Example_Live.res`](./examples/Example_Live.res)
