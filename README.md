# rescript-surrealdb

ReScript bindings for the public [`surrealdb`](https://www.npmjs.com/package/surrealdb) JavaScript SDK.

The package stays close to the upstream SDK shape. The top-level module is `Surrealdb`, with grouped modules for connections, queries, live queries, values, and errors.

## Install

```sh
npm install surrealdb rescript-surrealdb
```

`surrealdb` is a peer dependency.

Supported upstream SDK range: `^2.0.3`.

## Example

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

More examples:

- [Connect](https://github.com/em/rescript-surrealdb/blob/main/examples/Example_Connect.res)
- [Query](https://github.com/em/rescript-surrealdb/blob/main/examples/Example_Query.res)
- [Live](https://github.com/em/rescript-surrealdb/blob/main/examples/Example_Live.res)

## Package Layout

- `Surrealdb.Connection`: client, session, engine, and feature bindings
- `Surrealdb.Query`: query builders and query execution
- `Surrealdb.Live`: live query subscriptions and frame/message types
- `Surrealdb.Values`: SurrealDB value classes and codecs
- `Surrealdb.Errors`: client and server error bindings
- `Surrealdb.Api`: HTTP API bindings

The public export map lives in [`src/Surrealdb.resi`](./src/Surrealdb.resi).

## Development

```sh
npm install
npm run build
npm test
```

`npm test` is the full verification command for this repo.

CI also uses a unit-only split and an explicit live split:

```sh
npm run test:unit
npm run test:live
```

For manual local work with a foreground SurrealDB process:

```sh
npm run db:start
```

## Releases

User-facing changes go through Changesets.

Publishing is owned by GitHub Actions in [`.github/workflows/release.yml`](./.github/workflows/release.yml). Local shells do not publish this package.

## Maintainer Docs

- [Type fidelity notes](https://github.com/em/rescript-surrealdb/blob/main/docs/TYPE_FIDELITY.md)
- [Soundness audit](https://github.com/em/rescript-surrealdb/blob/main/docs/TYPE_SOUNDNESS_AUDIT.md)
- [Soundness matrix](https://github.com/em/rescript-surrealdb/blob/main/docs/SOUNDNESS_MATRIX.md)
- [Binding proof process](https://github.com/em/rescript-surrealdb/blob/main/docs/process/BINDING_PROOF_PROCESS.md)
- [README contract](https://github.com/em/rescript-surrealdb/blob/main/docs/process/README_CONTRACT.md)

This repo uses Codex-assisted binding authorship. Material Codex-assisted changes are credited in git history, and non-trivial public binding changes carry written audits and soundness coverage records.
