# Query Timeout And Health Runtime Audit

## Claim

- subsystem: query timeout helpers and connection health probing
- change: determine whether the current public package can honestly treat builder `timeout()` helpers and `health()` on `ws/rpc` as release-healthy supported surfaces
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
  - `tests/query/SurrealdbPromiseConfig_test.res` currently expects:
    - `TIMEOUT TIMEOUT 5s`
  - `tests/connection/SurrealdbSessionSurface_test.res` currently expects:
    - `health()` over `ws/rpc` yields a classified `not_found`
- direct consumer probe from `statespace`:
  - `rescript-surrealdb@2.0.0`
  - `surrealdb@2.0.3`
  - `db.health()` on `ws://127.0.0.1:8787/rpc` returned `Method not found`
  - `statespace` CLI still blocks `--timeout` because the package path emits invalid timeout SQL

## Local Representation

- timeout helpers are still exposed as ordinary public builder methods
- `health()` is still exposed as an ordinary public connection method
- package tests currently encode the failure modes as passing expectations

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

- status: REJECTED as release-healthy
- reviewer: Codex
- date: 2026-04-24

## Required Correction

1. Timeout helpers must stop shipping as an apparently healthy supported surface while direct proof still shows broken query text.
2. `health()` must stop shipping as an apparently healthy supported `ws/rpc` surface while direct proof still shows `Method not found`.
3. Tests that currently encode those broken outcomes must be reclassified as blocker evidence, not success evidence.
4. The next release must close the blocker by either:
   - fixing the supported path end to end, or
   - narrowing the public contract and package docs so the broken path is no longer claimed as supported.
