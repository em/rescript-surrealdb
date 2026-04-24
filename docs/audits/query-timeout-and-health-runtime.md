# Query Timeout And Health Runtime Audit

## Claim

- subsystem: query timeout helpers and connection health probing
- change: determine whether the current public package can honestly treat builder `timeout()` helpers and `health()` on `ws/rpc` as release-healthy supported surfaces, and if not, what narrowed public contract closes that lie
- boundary class:
  - package-authored support claim over forwarded upstream methods
  - runtime support boundary on the ordinary consumer path
- affected public surface:
  - `src/query/Surrealdb_Select.resi`
  - `src/query/Surrealdb_Create.resi`
  - `src/query/Surrealdb_Update.resi`
  - `src/query/Surrealdb_Upsert.resi`
  - `src/query/Surrealdb_Delete.resi`
  - `src/query/Surrealdb_Insert.resi`
  - `src/query/Surrealdb_Relate.resi`
  - `src/connection/Surrealdb_Surreal.resi`
  - `src/connection/Surrealdb_RpcEngine.resi`

## Upstream Evidence

### Declaration Evidence

- file: `node_modules/surrealdb/dist/surrealdb.d.ts`
  - relevant shape:
    - builder classes expose `.timeout(...)`
    - `Surreal` exposes `health(): Promise<void>`

### Runtime Evidence

- direct package tests:
  - current narrowing tests now prove:
    - builder `timeout` helpers are absent from the public binding files
    - explicit raw query text with `TIMEOUT` still works on the exercised server path
    - `health` is absent from the public binding files
- direct consumer probe from `statespace`:
  - `rescript-surrealdb@2.0.0`
  - `surrealdb@2.0.3`
  - `db.health()` on `ws://127.0.0.1:8787/rpc` returned `Method not found`
  - `statespace` CLI still blocks `--timeout` because the package path emits invalid timeout SQL

## Local Representation

- timeout helpers are no longer exposed on the public CRUD/select/relate builder modules
- `health()` is no longer exposed on the public `Surrealdb_Surreal` and `Surrealdb_RpcEngine` modules
- package tests no longer encode the failure modes as passing expectations

## Adversarial Questions

- question: if the binding faithfully forwards the upstream method, why is this still a package problem
- answer: a public binding package is responsible for truthful support claims on its exported surface. A forwarded method that deterministically emits broken output or deterministically fails on the package's ordinary supported transport path is still a package-level release blocker until the contract is narrowed or the path is fixed.

- question: can a regression test that proves the failure count as healthy coverage
- answer: no. That test is useful only as evidence for an open blocker. It cannot serve as release-closing proof while the public surface still claims the method as supported.

## Failure Modes Targeted

- failure mode: consumers rely on builder `timeout()` and emit invalid `TIMEOUT TIMEOUT` SurrealQL
  - current exposure:
    - `tests/query/SurrealdbPromiseConfig_test.res` proves the broken output instead of blocking it
    - `statespace` disables timeout usage locally

- failure mode: consumers rely on `health()` over `ws/rpc` as a supported readiness probe and hit `Method not found`
  - current exposure:
    - `tests/connection/SurrealdbSessionSurface_test.res` treats that failure as success
    - `statespace` traps and rewrites the failure locally

## Verdict

- status: ACCEPTED ONLY AS A NARROWED CONTRACT
- reviewer: Codex
- date: 2026-04-24

## Correction Applied

1. The public builder `timeout` helpers were removed from the binding surface instead of continuing to forward a known-broken upstream path.
2. The public `health()` helpers were removed from the `ws/rpc` binding surface instead of continuing to imply support where direct runtime proof only showed failure.
3. The old tests that treated those broken outcomes as success were replaced.
4. The package now documents the narrowed contract in `docs/TYPE_FIDELITY.md`, `docs/TYPE_SOUNDNESS_AUDIT.md`, and `docs/RELEASE_BLOCKERS.md`.
