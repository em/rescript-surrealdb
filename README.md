# rescript-surrealdb

`rescript-surrealdb` is a reusable ReScript binding package for the public SurrealDB JavaScript SDK.

## Goals

- Bind the actual public `surrealdb` SDK surface.
- Preserve typed SurrealDB runtime classes as opaque ReScript types.
- Keep the package generic and reusable outside any single app.
- Verify the binding surface with Vitest plus live SDK execution against a local SurrealDB instance.

## Maintenance Model

This package is maintained with Codex-assisted binding authorship.

Non-trivial public binding changes carry a written audit record, adversarial review, in-source rationale at important boundaries, and targeted soundness coverage. Material Codex-assisted commits are credited in git history with a Codex co-author trailer.

The maintainer workflow is documented in [`docs/process/BINDING_PROOF_PROCESS.md`](./docs/process/BINDING_PROOF_PROCESS.md), and the current boundary coverage inventory lives in [`docs/SOUNDNESS_MATRIX.md`](./docs/SOUNDNESS_MATRIX.md).

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
npm run db:start
```

`npm test` is the package verification command. It builds the ReScript sources, runs the full Vitest suite, and provisions an isolated local SurrealDB server automatically unless you point it at an explicit disposable test endpoint with `SURREALDB_TEST_ENDPOINT`.

`npm test` also runs the V8 coverage report on every test run. Coverage is part of the default verification path, not a separate command.

`npm run db:start` starts a foreground local SurrealDB server for manual development with defaults `127.0.0.1:8000`, `root`, `root`, and `memory` storage. Override those with `SURREALDB_BIND`, `SURREALDB_USER`, `SURREALDB_PASS`, `SURREALDB_LOG_LEVEL`, `SURREALDB_STORAGE`, or `SURREALDB_SERVER_BIN`.

`npm test` uses `SURREALDB_TEST_ENDPOINT` only when you explicitly provide a disposable test instance. Without that env var, it starts its own isolated local `surreal start ...` process, allocates a fresh namespace and database for the run, and tears the process down afterward. It does not attach to arbitrary local SurrealDB servers.

If `surreal` is not on `PATH`, set one of:

```sh
SURREALDB_TEST_SERVER_BIN=/absolute/path/to/surreal npm test
SURREALDB_TEST_SERVER_CMD='surreal' npm test
```

The launcher also auto-detects the common local install path `/home/m/.surrealdb/surreal` when present.

## Release Management

- Versioning is managed with Changesets.
- Run `npm run changeset` for any user-facing package change.
- The `release.yml` workflow opens or updates the release PR on `main`.
- Merging that release PR runs `npm run release:ci` in GitHub Actions and publishes to npm.
- Publishing is configured for npm trusted publishing from GitHub Actions, so there is no npm token to rotate once the package is linked on npm.
- Local shells do not publish this package. Do not run `npm publish` or `npm run release` locally.

## Docs

- [`docs/TYPE_FIDELITY.md`](./docs/TYPE_FIDELITY.md)
- [`docs/TYPE_SOUNDNESS_AUDIT.md`](./docs/TYPE_SOUNDNESS_AUDIT.md)
- [`docs/SOUNDNESS_MATRIX.md`](./docs/SOUNDNESS_MATRIX.md)

## Examples

- [`examples/Example_Connect.res`](./examples/Example_Connect.res)
- [`examples/Example_Query.res`](./examples/Example_Query.res)
- [`examples/Example_Live.res`](./examples/Example_Live.res)
