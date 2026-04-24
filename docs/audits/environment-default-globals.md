# Environment Default Globals Audit

## Claim

- subsystem: connection surface
- change: make `Surrealdb_Surreal.defaultWebSocketImpl` optional and stop evaluating `WebSocket` at module load
- boundary class: environment-dependent runtime global
- exact public surface affected:
  - `src/connection/Surrealdb_Surreal.resi`
  - `src/support/Surrealdb_Interop.js`

## Upstream Evidence

### Runtime Evidence

- command or probe:
  - `node --input-type=module -e "delete globalThis.WebSocket; await import('./src/query/Surrealdb_Run.mjs)"`
- result:
  - the previous binding crashed during module import because it read `WebSocket` eagerly
  - the new binding loads successfully and exposes the value as `option<websocketImpl>`

## Local Representation

- chosen shape:
  - `defaultWebSocketImpl` now reads from a function that returns `globalThis.WebSocket` or `undefined`
  - the public `.resi` surface now exposes `option<Surrealdb_DriverOptions.websocketImpl>`

## Alternatives Considered

### Alternative 1

- representation: keep `defaultWebSocketImpl` as a non-optional value
- why rejected: it crashes on environments where `WebSocket` is absent and claims a precision the runtime does not provide

### Alternative 2

- representation: remove the binding entirely
- why rejected: callers still benefit from a truthful way to reuse the current global when it exists

## Adversarial Questions

- question: does the optional binding weaken useful environments
- evidence-based answer: no. Browser-like environments still return `Some(websocketImpl)`. The change only stops the binding from lying in environments where no global exists.

- question: why not normalize the environment with a package-owned polyfill
- evidence-based answer: that would be a package-authored transport decision, not a truthful binding of the current runtime environment.

## Evidence

### Build

- command: `npm run build`
- result: passed

### Tests

- commands:
  - `npm test`
  - `npm run test:unit`
  - `npm run test:live`
- result:
  - all passed after the boundary was made optional

## Verdict

- status:
  - acceptable with documented fidelity gap
- reviewer: Codex
- date: 2026-04-22
