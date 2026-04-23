# Release Blockers

This file is the active release gate for `rescript-surrealdb`.

## Current Status

The 2026-04-23 soundness pass closed the original four blocker rows, but the release gate is now reopened.

New blocker evidence:

- audit: `docs/audits/query-timeout-and-health-runtime.md`
- direct tests currently locking in broken behavior:
  - `tests/query/SurrealdbPromiseConfig_test.res`
  - `tests/connection/SurrealdbSessionSurface_test.res`
- external user evidence:
  - `statespace` CLI currently disables `--timeout`
  - `statespace` CLI currently rewrites `health()` failures on `ws/rpc`

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
  - the upstream declaration evidence and the current public type-state are recorded in `docs/audits/release-blocker-closure.md`

## Blocker 3: Public Open Boundaries Still Hide Consumer Friction

- status: CLOSED on 2026-04-23
- closure:
  - `RangeBound` constructor input is now a closed recursive supported subset instead of a raw `unknown` or a broader classifier type
  - `RecordId.idValue` now exposes the supported recursive subset and returns `option<idValue>` for the intentionally unsupported remainder
  - codec boundaries remain explicitly open only where the upstream contract is genuinely dynamic
  - direct boundary tests now exercise the remaining open boundaries without package-local `%identity` helpers standing in for the public call shape

## Blocker 4: Compound `RecordId.idValue` Fidelity Is Still Only Partially Proved

- status: CLOSED on 2026-04-23
- closure:
  - the supported compound-id surface is now modeled explicitly with recursive components instead of a JSON projection
  - unsupported nested leaves stay explicit through `option<idValue>`
  - runtime probes and direct tests cover nested arrays, nested objects, nested value-class leaves, and unsupported nested function leaves
  - the supported subset and unsupported remainder are recorded in `docs/TYPE_FIDELITY.md` and `docs/audits/release-blocker-closure.md`

## Release Rule

The next release is blocked until every open row below is closed in code, docs, and tests.

### Blocker 5: Timeout helpers currently prove and ship broken SurrealQL

- status: OPEN on 2026-04-24
- evidence:
  - `tests/query/SurrealdbPromiseConfig_test.res` currently expects `TIMEOUT TIMEOUT 5s`
  - `statespace` disables `--timeout` because the package emits invalid timeout SQL
- required closure:
  - the timeout helper surface must produce correct SurrealQL or be narrowed so the package no longer claims a working timeout helper on paths where it is broken
  - tests must stop treating the broken `TIMEOUT TIMEOUT` output as success
  - direct runtime proof and direct binding tests must show timeout works on the supported path

### Blocker 6: `health()` on the supported `ws/rpc` path currently ships as a known failing surface

- status: OPEN on 2026-04-24
- evidence:
  - `tests/connection/SurrealdbSessionSurface_test.res` currently treats the installed `Method not found` failure as passing behavior
  - `statespace` traps and rewrites this failure in its CLI
- required closure:
  - the package must either restore a working supported health surface on `ws/rpc` or explicitly narrow the public contract so it no longer implies that `Surrealdb_Surreal.health` is a healthy supported call on that path
  - tests must stop treating the broken runtime path as a successful release proof
  - the final package docs must state the supported transport/runtime matrix for `health()`
