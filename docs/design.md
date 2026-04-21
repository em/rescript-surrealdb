# Design

## Package boundaries

The package is organized around public SurrealDB SDK nouns instead of app-specific call sites:

- `src/api/`
- `src/connection/`
- `src/errors/`
- `src/live/`
- `src/query/`
- `src/support/`
- `src/value/`

## Public API shape

`src/Surrealdb.res` is the single top-level export map. It groups the binding surface by concept while still leaving the underlying concrete modules available for direct import.

The export map is intentionally thin:

- No invented wrapper APIs.
- No narrowing to app-specific workflows.
- No JSON flattening over typed SDK value classes.

## Testing model

Tests are split between:

- construction and surface tests for bound classes and query builders
- live execution tests against a real local SurrealDB instance
- round-trip tests for typed values and query output

Vitest runs in Node and provisions a Docker-backed local SurrealDB server for the live suite when no explicit endpoint is provided.
