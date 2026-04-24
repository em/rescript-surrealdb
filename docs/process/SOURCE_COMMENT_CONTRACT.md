# Source Comment Contract

## Purpose

Important binding rationale must live in source, not only in external docs.

External docs explain the decision globally. Source comments explain the local reason a specific module or hazardous boundary has the shape it has.

## Rule

Do not add commentary everywhere. Add comments where a later maintainer could otherwise misread the code and "simplify" it into an unsound binding.

## Mandatory Comment Sites

Add or update source comments when touching:

- modules with public `unknown`
- modules with public or internal `%identity`, `Obj.magic`, or `%raw`
- public `*Raw` APIs
- generic boundaries where TypeScript expressivity exceeds ReScript expressivity
- runtime classification code
- package-authored APIs that are not direct upstream exports

## Required Comment Shapes

### Module Header Comment

Use a short header near the top of the module when the module owns a non-obvious boundary.

Required fields:

- `Concern:`
- `Source:`
- `Boundary:`
- `Why this shape:`
- `Coverage:`

Optional fields:

- `Audit:`
- `Soundness condition:`
- `When to revisit:`

### Local Hazard Comment

Add a short local comment immediately above a hazardous site when the local reason matters and is not obvious from the module header.

Required content:

- what runtime fact justifies the code
- what mistake the comment is preventing
- what test, matrix row, or audit would catch drift when the site is part of a public soundness boundary

## What Comments Must Prove

A good source comment answers at least one of these:

- why this is `unknown` instead of a closed type
- why this `%identity` is safe
- why this `*Raw` API remains public
- why this package-authored API exists even though the repo prefers thin bindings
- what direct test is supposed to fail if this boundary becomes dishonest

## What Comments Must Not Do

- restate obvious code
- describe syntax
- claim safety without naming the runtime fact that proves it
- claim exactness when the module is actually a documented fidelity gap
- duplicate large sections of the audit doc verbatim

## Review Rule

If a later change removes a comment-worthy boundary, remove or tighten the comment too. Stale rationale comments are defects.
