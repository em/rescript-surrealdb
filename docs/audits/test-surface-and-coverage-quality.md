> Historical contaminated audit. References below to consumer proof are rejected and non-authoritative. Current authority is direct repo-owned `npm test` / Vitest evidence for the binding surface.

# Test Surface And Coverage Quality Audit

Date: 2026-04-23

## Scope

This audit reviews whether the current `rescript-surrealdb` tests actually exercise the public binding surface in the way a strong industrial binding package should.

It focuses on:

- real runtime proof versus internal reconstruction
- tautological runtime-class and helper tests
- package-local `%identity` and `unknown` helpers in tests
- whether the current coverage gate is strong enough to catch public-surface fraud

## Current Workspace State

- `npm run build`: failing
- `npm test`: failing because the package does not currently build

Current build failure:

- `src/api/Surrealdb_Api.resi` has an incomplete signature rewrite around the new API promise-state refactor

So this audit reviews test quality from the current test sources plus the last known runnable suite structure. It does not treat the current suite as executable release proof.

## Inventory

- test files: `9`
- helper-cast test files: `6`
- helper-cast hits: `158`
- integration-style files touching live server behavior: `5`
- global coverage threshold in `vitest.config.js`: `50` for statements, branches, functions, and lines

## What Is Strong

### Real server-backed integration tests exist

The strongest tests in the repo are:

- `tests/connection/SurrealdbSessionSurface_test.res`
- `tests/live/SurrealdbStreamUtility_test.res`

Why they matter:

- they use a real SurrealDB server
- they exercise connect/auth/use/query/live behavior
- they test actual runtime classes and async behavior instead of only fake objects

### Codec tests target real boundary redesigns

- `tests/value/SurrealdbBindingValue_test.res`

This suite directly checks:

- `CborCodec.decodeWith`
- `ValueCodec.decodeWith`
- rejection behavior when the caller-supplied decoder does not accept the value

That is real boundary proof and exactly the kind of targeted test a binding package should have.

### Error and value classifier tests are meaningful

- `tests/errors/SurrealdbErrorPayloadSurface_test.res`
- `tests/errors/SurrealdbErrorSupport_test.res`
- `tests/value/SurrealdbValueSurface_test.res`

These are not pure tautology. They do exercise important runtime classification behavior.

## What Is Weak Or Fraudulent

### The suite still relies too heavily on package-local `%identity` to reach public seams

Representative files:

- `tests/query/SurrealdbPublicSurface_test.res`
- `tests/value/SurrealdbValueSurface_test.res`
- `tests/value/SurrealdbBindingValue_test.res`
- `tests/connection/SurrealdbSessionSurface_test.res`
- `tests/errors/SurrealdbErrorPayloadSurface_test.res`
- `tests/errors/SurrealdbErrorSupport_test.res`

These tests use:

- `%identity`
- `toUnknown`
- `dictToUnknown`
- `intToUnknown`
- `stringToUnknown`
- `floatToUnknown`
- `nullableToUnknown`

These helpers are acceptable when testing intentionally open classifier seams. They are not acceptable as the main proof that ordinary typed consumers can use the public API directly.

### `RangeBound` consumer friction was not caught by the suite

The external consumer review showed that a normal external consumer could not call:

- `Surrealdb_RangeBound.included(rid)`

without dropping to `unknown`.

The internal suite still passed because it drove that boundary through local `%identity` helpers:

- `tests/query/SurrealdbPublicSurface_test.res`
- `tests/value/SurrealdbValueSurface_test.res`

That is a direct example of internal proof overstating consumer proof.

### Many public-surface tests are still runtime-shape-heavy rather than consumer-ergonomics-heavy

Representative file:

- `tests/value/SurrealdbValueSurface_test.res`

This file has plenty of real value, but large parts of it still look like:

- construct runtime class
- call getter
- compare strings
- call `isInstance`
- call `fromUnknown`

That is useful. It is not enough by itself for the strongest public boundaries now under refactor:

- output-domain modeling
- `.json()` state transitions
- consumer-usable open boundaries

### The current suite does not yet prove the new promise-builder model

The package is now refactoring:

- CRUD/query/live/auth/api output domains
- explicit `.json()` state

The current tests do not yet provide the required direct proof for that redesign.

Missing proof classes:

- tests that fail if `.json()` preserves the wrong public payload state
- tests that fail if resolved outputs still leak input-side binding domains
- clean external consumer proofs for the redesigned promise-builder path

### The global coverage gate is too weak to support release claims

`vitest.config.js` still uses a flat `50` threshold for:

- statements
- branches
- functions
- lines

That is only a smoke gate. It is not evidence that the important public boundaries are actually covered.

For this package, a green global threshold can still coexist with:

- weak promise-builder fidelity
- `.json()` state erasure
- consumer friction on open boundaries
- raw helper casts standing in for consumer proof

## Representative Classification

### Tests that should count as strong release evidence

- `tests/connection/SurrealdbSessionSurface_test.res`
- `tests/live/SurrealdbStreamUtility_test.res`
- `tests/value/SurrealdbBindingValue_test.res`

### Tests that should count as boundary-internal evidence only

- `tests/query/SurrealdbPublicSurface_test.res` where it reaches open boundaries through `%identity`
- `tests/value/SurrealdbValueSurface_test.res` where it reconstructs boundary inputs through local casts
- classifier tests that inspect raw/open boundaries only through local helper casts

### Proof that is still missing

- clean external consumer compile proof for the redesigned CRUD/query/live/auth/api surface
- direct tests for `.json()` state transitions
- clean external consumer proof for `RangeBound` and other open public boundaries on the typed 99% path

## Verdict

This suite is stronger than the MCP suite because it has real server-backed runtime tests and better direct boundary tests.

It is still not at the level expected from a strong industrial binding package, because it still lets package-local helper casts and global coverage numbers overstate the quality of public consumer proof.

## Required Correction

### 1. Split the suite into explicit proof classes

The repo should distinguish:

- typed consumer proof
- open-boundary classifier proof
- runtime class smoke tests
- live integration proof

Those are not interchangeable.

### 2. Add direct proof for the current refactor

The package must add tests and consumer proofs for:

- resolved output-domain modeling
- `.json()` state transitions
- the public promise-builder path after the redesign

### 3. Stop treating helper-cast tests as consumer proof

If a test uses package-local `%identity` or `*ToUnknown` helpers, it must be classified as:

- open-boundary proof
- internal reconstruction proof

It must not be cited as proof that an ordinary typed consumer can use that surface directly.

### 4. Treat the global coverage threshold as smoke only

The current `50` threshold must not be cited as release evidence.

Release confidence for this package must come from:

- blocker-closing tests
- clean external consumer proofs
- module-level boundary coverage in the soundness matrix

## Release Blocker Mapping

This audit reinforces:

- `docs/RELEASE_BLOCKERS.md` Blocker 1
- `docs/RELEASE_BLOCKERS.md` Blocker 2
- `docs/RELEASE_BLOCKERS.md` Blocker 3
- `docs/RELEASE_BLOCKERS.md` Blocker 4
