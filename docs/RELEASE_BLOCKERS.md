# Release Blockers

This file is the active release gate for `rescript-surrealdb`.

## Current Status

The 2026-04-23 soundness pass closed the original four blocker rows.

The 2026-04-24 timeout and `health()` blocker rows are now closed by narrowing the unsupported public contract instead of continuing to ship broken forwarded methods.

Current remaining release gate outside those rows:

- `npm run build` passes
- `npm test` still fails the enforced global 80% coverage threshold
  - current global coverage from `npm test`: 59.62% statements, 55.1% functions, 59.62% lines
- current narrowing audit: `docs/audits/query-timeout-and-health-runtime.md`

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
  - direct boundary tests now exercise the remaining open boundaries without package-local `%identity` cast functions standing in for the public call shape

## Blocker 4: Compound `RecordId.idValue` Fidelity Is Still Only Partially Proved

- status: CLOSED on 2026-04-23
- closure:
  - the supported compound-id surface is now modeled explicitly with recursive components instead of a JSON projection
  - unsupported nested leaves stay explicit through `option<idValue>`
  - runtime probes and direct tests cover nested arrays, nested objects, nested value-class leaves, and unsupported nested function leaves
  - the supported subset and unsupported remainder are recorded in `docs/TYPE_FIDELITY.md` and `docs/audits/release-blocker-closure.md`

## Release Rule

The next release is blocked until every open row below is closed in code, docs, and tests.

### Blocker 5: Timeout methods currently prove and ship broken SurrealQL

- status: CLOSED on 2026-04-24
- closure:
  - `Surrealdb_Select.timeout`
  - `Surrealdb_Create.timeout`
  - `Surrealdb_Update.timeout`
  - `Surrealdb_Upsert.timeout`
  - `Surrealdb_Delete.timeout`
  - `Surrealdb_Insert.timeout`
  - `Surrealdb_Relate.timeout`
  - were removed from the public binding surface in both `.resi` and generated `.mjs`
  - `tests/query/SurrealdbPromiseConfig_test.res` now proves the remaining supported builder configuration path and proves the timeout methods are absent from the published binding files
  - `tests/connection/SurrealdbSessionSurface_test.res` now proves explicit raw SurrealQL with `TIMEOUT` still works on the supported `Query.text` path against the exercised server

### Blocker 6: `health()` on the supported `ws/rpc` path currently ships as a known failing surface

- status: CLOSED on 2026-04-24
- closure:
  - `Surrealdb_Surreal.health`
  - `Surrealdb_RpcEngine.health`
  - were removed from the public binding surface in both `.resi` and generated `.mjs`
  - `tests/connection/SurrealdbSessionSurface_test.res` now proves the `health` exports are absent from the published binding files
  - package docs now state that no supported `ws/rpc` health surface is claimed by this binding
