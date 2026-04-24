# Remote Engine Factory Boundary Audit

## Claim

- subsystem: connection
- change: break the `DriverContext -> DriverOptions -> RemoteEngines` cycle by keeping remote engine factories opaque and invoking them through `Surrealdb_DriverContext.instantiate`
- boundary class: package-authored API surface around an upstream function-valued record
- exact public surface affected:
  - `src/connection/Surrealdb_DriverContext.resi`
  - `src/connection/Surrealdb_RemoteEngines.resi`
  - `src/query/Surrealdb_Query.resi`

## Upstream Evidence

### Official Docs

- URL: https://surrealdb.com/docs/sdk/javascript/engines/node
  - relevant excerpt or summary: the docs show `engines` as a plain object built by spreading `createRemoteEngines()` and `createNodeEngines()`, which means the public SDK surface is a string-keyed record of engine factories rather than a named class API.
- URL: https://surrealdb.com/blog/introducing-javascript-sdk-2-0
  - relevant excerpt or summary: the Diagnostics API wraps `applyDiagnostics(createRemoteEngines(), callback)` and emits events with `type`, `key`, and `phase`, so the binding must preserve diagnostics wrapping on the same engines record.
- URL: https://rescript-lang.org/docs/manual/bind-to-js-object/
  - relevant excerpt or summary: ReScript distinguishes fixed-field objects from hash map-like JS objects and recommends `Dict`-style modeling for dynamic string-keyed objects, which matches the SDK `Engines` record.

### Declaration Evidence

- file: `node_modules/surrealdb/dist/surrealdb.d.ts`
  - relevant signature:
    - `type EngineFactory = (context: DriverContext) => SurrealEngine`
    - `type Engines = Record<string, EngineFactory>`
    - `interface DriverOptions { engines?: Engines; ... }`
    - `interface DriverContext { options: DriverOptions; uniqueId: () => string; codecs: CodecRegistry }`
    - `export declare const createRemoteEngines: () => Engines`
    - `export declare const applyDiagnostics: (engines: Engines, callback: DiagnosticsCallback) => Engines`

### Runtime Evidence

- command or probe: `sed -n '1,120p' src/connection/Surrealdb_DriverContext.mjs` and `sed -n '1,120p' src/connection/Surrealdb_RemoteEngines.mjs`
- result: emitted JS shows `instantiate(context, factory) { return callEngineFactory(context, factory); }` and `applyDiagnostics(engines, listener) { return Surrealdb.applyDiagnostics(engines, event => listener(Surrealdb_Value.fromUnknown(event))); }`, so the package API is a direct call-through and diagnostics still classify SDK events at the boundary.

## Local Representation

- affected files:
  - `src/connection/Surrealdb_DriverContext.res`
  - `src/connection/Surrealdb_DriverContext.resi`
  - `src/connection/Surrealdb_RemoteEngines.res`
  - `src/connection/Surrealdb_RemoteEngines.resi`
  - `src/support/Surrealdb_Interop.js`
  - `src/query/Surrealdb_Query.resi`
  - `tests/query/SurrealdbPublicSurface_test.res`
  - `tests/connection/SurrealdbSessionSurface_test.res`
  - `examples/Example_Query.res`
- chosen ReScript shape:
  - `Surrealdb_RemoteEngines.factory` stays opaque
  - `Surrealdb_DriverContext.instantiate` invokes one opaque factory with a typed `DriverContext`
  - `Surrealdb_RemoteEngines.applyDiagnostics` still classifies diagnostic payloads through `Surrealdb_Value.fromUnknown`
  - `Surrealdb_Query.resolve` is typed as `t<result> => promise<result>` to match its collected classified result surface

## Alternatives Considered

### Alternative 1

- representation: keep `Surrealdb_RemoteEngines.factory = Surrealdb_DriverContext.t => Surrealdb_Engine.t` and `RemoteEngines.instantiate`
- why rejected: that exact alias creates the circular dependency through `DriverOptions.engines` and leaves the package unable to build.

### Alternative 2

- representation: widen factory invocation or driver options to `unknown`
- why rejected: the SDK already gives an exact `DriverContext` and `Engines` contract. Replacing the cycle with public `unknown` would hide the problem instead of solving it honestly.

## Adversarial Questions

- question: why not expose the engines record as `dict<Surrealdb_DriverContext.t => Surrealdb_Engine.t>` publicly
- evidence-based answer: the SDK surface is a dynamic string-keyed object and ReScript module dependencies would still cycle through `DriverOptions`. Keeping factory values opaque preserves the JS record shape without reopening the cycle.

- question: does moving invocation to `DriverContext.instantiate` invent a false upstream API
- evidence-based answer: yes, it is a package-added API, and it is documented as package-added in `docs/TYPE_FIDELITY.md`. The API only performs the direct `factory(context)` call shown in emitted JS.

- question: could the package API break diagnostics behavior by changing the wrapped engine object
- evidence-based answer: no. `Surrealdb_RemoteEngines.applyDiagnostics` still delegates to the upstream `applyDiagnostics(engines, callback)` on the same engines record, and the direct connection test now observes the expected `open`, `version`, `use`, and `signin` phase events.

## Failure Modes Targeted

- failure mode: the binding cannot compile because `DriverContext`, `DriverOptions`, and `RemoteEngines` depend on each other recursively
- how the current design prevents or exposes it: the factory type is opaque in `RemoteEngines`, so the public dependency chain no longer loops
- test or probe covering it: `npm run build`

- failure mode: engine factory invocation widens the typed context into an unchecked public value hole
- how the current design prevents or exposes it: `Surrealdb_DriverContext.instantiate` is the only public invocation site and it accepts the concrete `DriverContext.t`
- test or probe covering it: `tests/query/SurrealdbPublicSurface_test.res`

- failure mode: diagnostics wrapping stops surfacing protocol events after the package API move
- how the current design prevents or exposes it: the diagnostics path still classifies upstream events through `Surrealdb_Value.fromUnknown` and the session test asserts the first eight lifecycle phases
- test or probe covering it: `tests/connection/SurrealdbSessionSurface_test.res`

- failure mode: `Query.resolve` claims a broader promise type than the collected query result boundary actually returns
- how the current design prevents or exposes it: `Surrealdb_Query.resolve` is now constrained to `result`, matching both implementation and example/test call sites
- test or probe covering it: `tests/connection/SurrealdbSessionSurface_test.res`, `examples/Example_Query.res`

## Evidence

### Build

- command: `npm run build`
- result: passed

### Tests

- command: `npx vitest run tests/query/SurrealdbPublicSurface_test.mjs tests/connection/SurrealdbSessionSurface_test.mjs --config vitest.config.js`
- result: passed, 31 tests
- command: `npm test`
- result: passed, 48 tests and coverage report
- command: `npm pack --dry-run`
- result: passed and produced `rescript-surrealdb-0.1.0.tgz`

### Emitted JS Inspection

- file or command: `sed -n '1,120p' src/connection/Surrealdb_DriverContext.mjs` and `sed -n '1,120p' src/connection/Surrealdb_RemoteEngines.mjs`
- result: verified the package API compiles to a direct `callEngineFactory(context, factory)` call and diagnostics remain a direct call around `Surrealdb.applyDiagnostics`

### Soundness Matrix Update

- affected row:
  - `Connection / remote engine factory invocation`
  - `Export/Package APIs / package-authored API surface`
- update made: added the direct engine-factory row and linked the package API surface to this audit

## Residual Risk

- remaining open boundary: `Surrealdb_RemoteEngines.factory` remains opaque and package-owned
- why it remains open: the SDK exposes function values inside a dynamic record, and ReScript cannot express that exact public shape here without reintroducing the module cycle
- where it is documented: `docs/TYPE_FIDELITY.md`, `docs/TYPE_SOUNDNESS_AUDIT.md`, `docs/SOUNDNESS_MATRIX.md`

## Verdict

- status:
  - acceptable with documented fidelity gap
- reviewer: Codex
- date: 2026-04-22
