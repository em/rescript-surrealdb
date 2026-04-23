# Audit Template

## Claim

- subsystem:
- change:
- boundary class:
- exact public surface affected:

## Upstream Evidence

### Official Docs

- URL:
- relevant excerpt or summary:

### Declaration Evidence

- file:
- relevant signature:

### Runtime Evidence

- command or probe:
- result:

## Local Representation

- affected files:
- chosen ReScript shape:

## Modeling-First Inventory

- exact or tighter model considered first:
- where real polymorphism is preserved:
- where runtime classes stay opaque:
- stricter supported subset chosen:
- unsupported or intentionally omitted upstream cases:
- irreducibly dynamic leaf, if any:
- surviving `unknown`, JSON, or `%identity` sites with reasons:

## Alternatives Considered

### Alternative 1

- representation:
- why rejected:

### Alternative 2

- representation:
- why rejected:

## Adversarial Questions

- question:
- evidence-based answer:

- question:
- evidence-based answer:

- question:
- evidence-based answer:

## Failure Modes Targeted

- failure mode:
- how the current design prevents or exposes it:
- test or probe covering it:

## Evidence

### Build

- command:
- result:

### Tests

- command:
- result:

### Emitted JS Inspection

- file or command:
- result:

### Soundness Matrix Update

- affected row:
- update made:

## Residual Risk

- remaining open boundary:
- why it remains open:
- where it is documented:

## Verdict

- status:
  - acceptable as exact binding
  - acceptable with documented fidelity gap
  - rejected pending redesign
- reviewer:
- date:
