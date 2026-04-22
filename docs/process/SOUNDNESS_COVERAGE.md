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

- public `unknown` inputs
- public `unknown` outputs
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
- source files
- test files
- audit file
- evidence status
- notes or residual risk

## Test Requirement

Every tracked boundary must have at least one direct test that targets the actual soundness risk.

The test must exercise the public boundary directly and would fail if the binding lied about the contract.

## Release Rule

`weak` and `missing` rows are release blockers unless the periodic audit explicitly carries them forward with a written reason, owner, and next review trigger.

## What Does Not Count

These do not count as soundness coverage by themselves:

- high aggregate coverage percentage
- compilation
- a generic integration test that incidentally passes through the boundary
- a test that never checks the specific failure mode the boundary is guarding against

## Required Review Questions

When updating the soundness matrix, ask:

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
