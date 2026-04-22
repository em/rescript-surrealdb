# Node 20 Runtime Compatibility Audit

## Claim

- subsystem: runtime support and live verification
- change:
  - provide a constructor-compatible WebSocket implementation during live tests on Node 20
  - replace `Array.fromAsync` with a manual async-iterator collector in shared support code
- exact files affected:
  - `tests/support/websocketSetup.mjs`
  - `vitest.config.js`
  - `vitest.live.config.js`
  - `src/support/Surrealdb_Interop.js`
  - `package.json`

## Failure Evidence

### GitHub Actions

- failing runs:
  - CI live job on commit `cbafad6`
  - CI live job on commit `6f12cf1`
- observed failures:
  - `TypeError: WebSocketImpl is not a constructor`
  - `TypeError: Array.fromAsync is not a function`

## Local Representation

- chosen shape:
  - live tests now install `ws` as `globalThis.WebSocket`
  - async iterable collection now uses `for await ... of` instead of `Array.fromAsync`

## Alternatives Considered

### Alternative 1

- representation: leave live tests dependent on the runner's built-in `WebSocket`
- why rejected: GitHub Node 20 exposed a non-constructor-compatible value for the SDK path under test

### Alternative 2

- representation: keep `Array.fromAsync`
- why rejected: Node 20 does not provide it, so the published package can fail on a supported runtime

## Adversarial Questions

- question: is the WebSocket fix changing the public binding contract
- evidence-based answer: no. It only stabilizes the live test environment so the package is verified against a real constructor-compatible WebSocket implementation.

- question: is the async iterable fix test-only
- evidence-based answer: no. `src/support/Surrealdb_Interop.js` is shipped runtime code, so the `Array.fromAsync` replacement is a real package fix and requires a patch release.

## Evidence

### Local Verification

- commands:
  - `npm run test:live`
  - `npm run test:unit`
  - `npm test`
- result:
  - all passed

### GitHub Verification

- workflow run:
  - `CI` on commit `ef36a14`
- result:
  - `live` passed
  - `unit` passed

## Verdict

- status:
  - patch release required
- reviewer: Codex
- date: 2026-04-23
