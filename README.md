# rescript-surrealdb

ReScript bindings for the official [`surrealdb`](https://www.npmjs.com/package/surrealdb) JavaScript SDK.

The package stays close to the upstream SDK shape, so the SurrealDB JavaScript docs map directly to the ReScript modules in this repo.

## Install

```sh
npm install surrealdb rescript-surrealdb
```

Add the package to `rescript.json`:

```json
{
  "dependencies": ["rescript-surrealdb"]
}
```

- `surrealdb` is a peer dependency
- supported SDK range: `surrealdb@^2.0.3`
- package engine requirement: `node >=20`

## Quick Start

```rescript
let run = async () => {
  let db = Surrealdb.Connection.Surreal.make()

  await Surrealdb.Connection.Surreal.connect(
    db,
    "ws://127.0.0.1:8787/rpc",
    ~namespace="test",
    ~database="app",
    ~authentication=
      Surrealdb.Connection.Surreal.rootConnectAuth(~username="root", ~password="root", ())
      ->Surrealdb.Connection.Surreal.staticAuthentication,
    ~versionCheck=false,
    (),
  )

  let values =
    await db
    ->Surrealdb.Query.Query.text("RETURN 1; RETURN 2;", ())
    ->Surrealdb.Query.Query.resolve

  let _ = await db->Surrealdb.Connection.Surreal.close
  values->Array.map(Surrealdb.Values.Value.toText)
}
```

## Package Guide

- `Surrealdb.Connection` covers client creation, authentication, sessions, engines, and transactions
- `Surrealdb.Query` covers text queries, query builders, frames, and response types
- `Surrealdb.Live` covers live subscriptions, messages, and frame handling
- `Surrealdb.Values` covers SurrealDB value classes, codecs, record IDs, ranges, and geometry values
- `Surrealdb.Errors` covers client, server, and classified error shapes
- `Surrealdb.Api` covers the HTTP API bindings

Official SDK docs:

- [SurrealDB JavaScript SDK](https://surrealdb.com/docs/sdk/javascript)
- [SurrealDB JavaScript data types](https://surrealdb.com/docs/sdk/javascript/core/data-types)

Examples:

- [Connect](https://github.com/em/rescript-surrealdb/blob/main/examples/Example_Connect.res)
- [Query](https://github.com/em/rescript-surrealdb/blob/main/examples/Example_Query.res)
- [Live queries](https://github.com/em/rescript-surrealdb/blob/main/examples/Example_Live.res)

## Development

```sh
npm install
npm run build
npm test
```

Additional local commands:

- `npm run test:unit`
- `npm run test:live`
- `npm run db:start`

## Release

Releases are versioned with Changesets and published by GitHub Actions through the repository workflow:

- [`.github/workflows/release.yml`](https://github.com/em/rescript-surrealdb/blob/main/.github/workflows/release.yml)
