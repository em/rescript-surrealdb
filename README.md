# rescript-surrealdb

`rescript-surrealdb` is a reusable ReScript binding package for the public SurrealDB JavaScript SDK.

## Goals

- Bind the actual public `surrealdb` SDK surface.
- Preserve typed SurrealDB runtime classes as opaque ReScript types.
- Keep the package generic and reusable outside any single app.
- Verify the binding surface with Vitest plus live SDK execution against a local SurrealDB instance.

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
```

The Vitest suite uses `SURREALDB_TEST_ENDPOINT` only when you explicitly provide a disposable test instance. Without that env var, the suite starts its own isolated Docker SurrealDB container, allocates a fresh namespace and database for the run, and tears the container down afterward. It does not auto-attach to arbitrary local SurrealDB servers.

## Docs

- [`docs/research.md`](./docs/research.md)
- [`docs/design.md`](./docs/design.md)
- [`TYPE_FIDELITY.md`](./TYPE_FIDELITY.md)

## Examples

- [`examples/Example_Connect.res`](./examples/Example_Connect.res)
- [`examples/Example_Query.res`](./examples/Example_Query.res)
- [`examples/Example_Live.res`](./examples/Example_Live.res)
