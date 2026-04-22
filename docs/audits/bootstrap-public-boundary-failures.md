# Bootstrap Public Boundary Failures Audit

## Claim

- subsystem: package-wide public boundary inventory
- change: record the main failure patterns that still require adversarial review and keep them out of ad hoc root notes
- boundary class: query result boundary, event payload boundary, nullable API boundary, package helper boundary
- exact public surface affected:
  - `src/query/Surrealdb_Query.resi`
  - `src/query/Surrealdb_QueryFrame.resi`
  - `src/live/Surrealdb_Publisher.resi`
  - `src/connection/Surrealdb_Session.resi`
  - `src/connection/Surrealdb_Surreal.resi`
  - `src/api/Surrealdb_ApiResponse.resi`
  - `src/query/Surrealdb_Export.resi`

## Upstream Evidence

### Official Docs

- URL: https://surrealdb.com/docs/sdk/javascript
  - relevant excerpt or summary: query execution, sessions, and live features are part of the public SDK surface and must remain recognizable in the binding.
- URL: https://surrealdb.com/docs/sdk/javascript/core/data-types
  - relevant excerpt or summary: runtime values cross these APIs as branded SDK classes plus ordinary JS containers and primitives.

### Declaration Evidence

- file: `node_modules/surrealdb/dist/surrealdb.d.ts`
  - relevant signature:
    - line 2037: `Publisher.subscribe<K extends keyof T>(event: K, listener: (...event: T[K]) => void): () => void`
    - line 3521: `query<R extends unknown[] = unknown[]>(query: string, bindings?: Record<string, unknown>): Query<R>`
    - line 3531: `query<R extends unknown[] = unknown[]>(query: BoundQuery<R>): Query<R>`
    - line 3734: `SurrealSession.subscribe<K extends keyof SessionEvents>(event: K, listener: (...payload: SessionEvents[K]) => void): () => void`
    - line 3904: `Surreal.subscribe<K extends keyof SurrealEvents>(event: K, listener: (...payload: SurrealEvents[K]) => void): () => void`

### Runtime Evidence

- command or probe: `NOT RUN in this documentation retrofit`
- result: this bootstrap audit records the failure classes and the current proof obligations; fresh runtime probes are required when these surfaces change.

## Local Representation

- affected files:
  - `src/query/Surrealdb_Query.resi`
  - `src/query/Surrealdb_QueryFrame.resi`
  - `src/live/Surrealdb_Publisher.resi`
  - `src/connection/Surrealdb_Session.resi`
  - `src/connection/Surrealdb_Surreal.resi`
  - `src/api/Surrealdb_ApiResponse.resi`
  - `src/query/Surrealdb_Export.resi`
- chosen ReScript shape:
  - query helpers resolve to `array<Surrealdb_Value.t>` and stream through `Surrealdb_QueryFrame.t`
  - event subscriptions accept an event string and deliver `array<Surrealdb_Value.t>`
  - helper surfaces remain public but must stay documented as package-added
  - nullable API and frame payload boundaries remain explicitly audited in `docs/SOUNDNESS_MATRIX.md`

## Alternatives Considered

### Alternative 1

- representation: translate query and event generics into public `'a` polymorphism everywhere
- why rejected: the runtime does not preserve those type parameters independently of query text or event name. That would be fake precision.

### Alternative 2

- representation: leave the repo state documented only by scratch `AUDIT` and `FRAUD` files in the root
- why rejected: root notes do not form a durable maintenance process, do not tie into the soundness matrix, and drift away from the current public surface.

## Adversarial Questions

- question: does `array<Surrealdb_Value.t>` on subscribe callbacks still lose too much upstream information
- evidence-based answer: yes, it loses keyed tuple specificity, and that loss is explicitly documented in `docs/TYPE_FIDELITY.md`. The remaining risk stays marked `weak` in the live rows of `docs/SOUNDNESS_MATRIX.md`.

- question: are package-added helpers easy to mistake for direct SDK exports
- evidence-based answer: yes unless the repo keeps them documented. `docs/TYPE_FIDELITY.md`, `README.md`, and the helper row in `docs/SOUNDNESS_MATRIX.md` now all mark them as package-authored.

- question: can a new agent still drift the README back into an agent notebook
- evidence-based answer: the repo now separates the human-facing landing page from the maintainer process, and `docs/process/README_CONTRACT.md` plus `AGENTS.md` make that split explicit.

## Failure Modes Targeted

- failure mode: query helpers pretend to preserve result typing beyond what query text proves
- how the current design prevents or exposes it: public helper results stay at `array<Surrealdb_Value.t>` and the fidelity gap is documented
- test or probe covering it: `tests/query/SurrealdbPublicSurface_test.res`

- failure mode: event payload tuples are treated as closed or event-specific when they are not
- how the current design prevents or exposes it: event name stays open, payloads are classified through `Surrealdb_Value.fromUnknown`, and the matrix keeps the current proof status explicit
- test or probe covering it: `tests/live/SurrealdbStreamUtility_test.res`, `tests/connection/SurrealdbSessionSurface_test.res`

- failure mode: helper APIs drift into undocumented pseudo-upstream surface
- how the current design prevents or exposes it: helpers are cataloged in `docs/TYPE_FIDELITY.md` and tracked as their own row in the soundness matrix
- test or probe covering it: `tests/query/SurrealdbPublicSurface_test.res`

- failure mode: nullable API and frame boundaries blur absence and payload shape
- how the current design prevents or exposes it: separate matrix rows keep these surfaces under explicit review instead of assuming they are already safe
- test or probe covering it: `tests/query/SurrealdbPublicSurface_test.res`

## Evidence

### Build

- command: `NOT RUN`
- result: this retrofit only reorganized process and audit documentation

### Tests

- command: `NOT RUN`
- result: future code-changing audits must refresh runtime evidence on the affected boundaries

### Emitted JS Inspection

- file or command: `NOT RUN`
- result: no new external was introduced by this documentation retrofit

### Soundness Matrix Update

- affected row:
  - `Query / dynamic result boundary`
  - `Query / query frame classification`
  - `Live / event payload boundary`
  - `API / nullable response fields`
  - `Export / Helpers / package-authored helper surface`
- update made: linked those rows to this bootstrap audit and moved the failure inventory into `docs/audits/`

## Residual Risk

- remaining open boundary: query result semantics, event payload tuples, nullable API details, and helper drift still need stronger direct tests and fresh runtime probes
- why it remains open: these are the hardest value-dependent parts of the SDK surface and the current repo inventory still marks several rows as `weak` or `partial`
- where it is documented: `docs/TYPE_FIDELITY.md`, `docs/TYPE_SOUNDNESS_AUDIT.md`, `docs/SOUNDNESS_MATRIX.md`

## Verdict

- status:
  - acceptable with documented fidelity gap
- reviewer: Codex
- date: 2026-04-22
