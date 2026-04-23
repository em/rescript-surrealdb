# Soundness Coverage Process

## Purpose

Soundness coverage is not the same thing as line coverage.

The goal is to ensure that every important public boundary is exercised by a test that would fail if the binding were lying about the contract.

## Living Artifact

`docs/SOUNDNESS_MATRIX.md` is the living inventory of important boundaries and the tests that justify them.

Update it whenever a non-trivial binding change lands.

Every row must stay connected to:

- at least one direct test file
- the owning source module
- the decision audit that explains why the boundary has its current shape

## Boundary Classes That Must Be Tracked

- exact-modeling opportunities that were rejected or accepted
- public `unknown` inputs
- public `unknown` outputs
- public JSON projections or package-authored narrowed JSON facades
- public `*Raw` APIs
- public `%identity`, `Obj.magic`, and `%raw` boundaries
- runtime class or instance classification
- nullish boundaries
- error classification boundaries
- package-authored helper surfaces

Project-specific boundary classes beyond these are listed in `AGENTS.md`.

## Required Matrix Fields

Each boundary row in `docs/SOUNDNESS_MATRIX.md` must identify:

- subsystem
- boundary
- risk
- strongest rejected tighter model
- unsupported upstream cases, if the chosen model deliberately excludes them
- source files
- test files
- audit file
- evidence status
- notes or residual risk

## Test Requirement

Every tracked boundary must have at least one direct test that targets the actual soundness risk.

The test must exercise the public boundary directly and would fail if the binding lied about the contract.

When the public boundary accepts `unknown` or another deliberately open foreign type, at least one proof must also show that a normal external consumer can use the boundary without package-local unsafe casts.

## Release Rule

`weak` and `missing` rows are release blockers unless the periodic audit explicitly carries them forward with a written reason, owner, and next review trigger.

## What Does Not Count

These do not count as soundness coverage by themselves:

- high aggregate coverage percentage
- a low global coverage threshold such as the current Vitest gate
- compilation
- a generic integration test that incidentally passes through the boundary
- a test that never checks the specific failure mode the boundary is guarding against
- a package-internal test that reaches a public `unknown` boundary only through local `%identity` helpers when no clean external consumer proof exists

Global coverage thresholds are smoke gates only.

They may detect a totally untested package. They do not prove that important public boundaries, typed consumer paths, compile-fail invariants, or release blockers are actually covered.

## Required Review Questions

When updating the soundness matrix, ask:

- could this boundary be modeled more exactly with a variant, record, opaque class, or narrower polymorphism
- did the package preserve the strict sound subset, or did it weaken the whole surface for a rare edge case
- what exact lie would this test catch
- does the test exercise the public boundary directly
- if the binding drifted from the upstream `.d.ts`, would this test fail
- is the risk already covered elsewhere, or is this assumed without proof

## Periodic Audit Rule

Before release, use the soundness matrix to identify:

- uncovered public boundaries
- stale tests
- tests that no longer match the current `.resi` surface
- documented fidelity gaps with missing targeted tests

Do not treat unresolved gaps as invisible debt. Mark them explicitly in the matrix.
