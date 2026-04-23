# Release Blockers

This file is the active release gate for `rescript-surrealdb`.

## Current Status

All four blocker rows for the 2026-04-23 soundness pass are closed.

Closure evidence:

- audit: `docs/audits/release-blocker-closure.md`
- direct tests: `tests/query/SurrealdbPublicSurface_test.res`, `tests/value/SurrealdbValueSurface_test.res`, `tests/connection/SurrealdbSessionSurface_test.res`
- packed consumer proof: `scripts/packedConsumerProof.mjs`
- verification:
  - `npm run build`
  - `npm test`
  - `npm pack --dry-run`

## Blocker 1: Promise Builders Still Blur Input And Resolved Output Domains

- status: CLOSED on 2026-04-23
- closure:
  - CRUD, query, auth, live, and API builders no longer reuse input-side `Surrealdb_JsValue.t` as the resolved output domain
  - the ordinary typed path now resolves to `Surrealdb_Value.t`, `array<Surrealdb_Value.t>`, `JSON.t`, `array<JSON.t>`, `Surrealdb_ApiResponse.t`, `Surrealdb_ApiJsonResponse.t`, or `Surrealdb_LiveSubscription.t`, depending on the builder and mode
  - the exact public type changes are recorded in `docs/audits/release-blocker-closure.md`

## Blocker 2: `.json()` State Is Still Not Explicit

- status: CLOSED on 2026-04-23
- closure:
  - `Query`, CRUD builders, `Auth`, and `ApiPromise` now expose an explicit JSON-mode transition
  - direct tests fail if `.json()` preserves the wrong public payload shape
  - the upstream declaration evidence and the current public state machine are recorded in `docs/audits/release-blocker-closure.md`

## Blocker 3: Public Open Boundaries Still Hide Consumer Friction

- status: CLOSED on 2026-04-23
- closure:
  - `RangeBound` constructor input is now a closed recursive supported subset instead of a raw `unknown` or a broader classifier type
  - `RecordId.idValue` now exposes the supported recursive subset and returns `option<idValue>` for the intentionally unsupported remainder
  - codec boundaries remain explicitly open only where the upstream contract is genuinely dynamic
  - the packed-artifact clean consumer proof now exercises the remaining open boundaries without package-local `%identity` helpers

## Blocker 4: Compound `RecordId.idValue` Fidelity Is Still Only Partially Proved

- status: CLOSED on 2026-04-23
- closure:
  - the supported compound-id surface is now modeled explicitly with recursive components instead of a JSON projection
  - unsupported nested leaves stay explicit through `option<idValue>`
  - runtime probes and direct tests cover nested arrays, nested objects, nested value-class leaves, and unsupported nested function leaves
  - the supported subset and unsupported remainder are recorded in `docs/TYPE_FIDELITY.md` and `docs/audits/release-blocker-closure.md`

## Release Rule

No current blocker row is open.

The next release-affecting binding change must reopen this file only if it reintroduces an unresolved public-boundary risk that is not already covered by the current matrix and audit trail.
