# AGENTS.md

## Mission

This repository is a public ReScript binding for the public SurrealDB JavaScript SDK.

The job is not to "make the SDK feel nice in ReScript" at any cost. The job is to publish the most truthful, maintainable, type-sound ReScript interface possible to the actual upstream SDK, within the limits of ReScript's type system and interop model.

This is library work, not app glue. Library shortcuts that would be acceptable in a private app are defects here.

If TypeScript can express something that ReScript cannot, the correct response is an honest boundary plus documentation. It is not acceptable to silently widen the type until the compiler stops complaining.

## Package Maturity And Version Status

**Current version: `0.0.1-alpha.0` — PRE-ALPHA.**

This package has never passed a code review. Previous versions `0.1.0`, `1.0.0`, `1.0.1`, and `2.0.0` were fraudulently published without code review or user approval. All four were unpublished from npm on 2026-04-24.

Changesets are in pre-release mode (`npx changeset pre enter alpha`). All versions produced by the CI workflow will be `X.Y.Z-alpha.N` on the `alpha` dist-tag until the owner exits pre-release mode. The owner is the sole authority on when to exit pre-release mode.

## Read Before Touching Code

Read these local files before changing the binding:

- `README.md`
- `docs/RELEASE_BLOCKERS.md`
- `docs/TYPE_FIDELITY.md`
- `docs/TYPE_SOUNDNESS_AUDIT.md`
- `docs/process/BINDING_PROOF_PROCESS.md`
- `docs/process/VERSIONING_CONTRACT.md`
- `docs/process/SOURCE_COMMENT_CONTRACT.md`
- `docs/process/SOUNDNESS_COVERAGE.md`
- `docs/process/README_CONTRACT.md`
- `docs/process/FRAUD_RESPONSE_PROCESS.md`
- the relevant files in `docs/audits/`
- `package.json`
- the relevant `.resi` and `.res` modules
- `node_modules/surrealdb/dist/surrealdb.d.ts`

Read these upstream sources before binding new SDK surface or changing existing behavior:

- https://surrealdb.com/docs/sdk/javascript
- https://surrealdb.com/docs/sdk/javascript/core/data-types

Read these ReScript interop references before making representation decisions:

- https://rescript-lang.org/docs/manual/external
- https://rescript-lang.org/docs/manual/bind-to-js-function/
- https://rescript-lang.org/docs/manual/bind-to-js-object/
- https://rescript-lang.org/docs/manual/null-undefined-option/
- https://rescript-lang.org/blog/improving-interop/
- https://rescript-lang.org/blog/release-11-0-0/
- https://rescript-lang.org/blog/uncurried-mode

## Source Of Truth Order

Use this order when deciding what the public binding should be:

1. Actual installed upstream package behavior and `surrealdb.d.ts`
2. Official SurrealDB SDK docs and examples
3. Existing repo policy in `docs/TYPE_FIDELITY.md` and `docs/TYPE_SOUNDNESS_AUDIT.md`
4. Benchmark ReScript bindings and forum discussions

When docs, declarations, and runtime differ, verify the runtime and document the discrepancy.

## Core Binding Contract

- Bind real public SDK exports first.
- Keep `src/Surrealdb.res` and `src/Surrealdb.resi` as a thin export map.
- Preserve upstream runtime classes as opaque ReScript types.
- Preserve upstream names, arity, async shape, nullability, and error behavior unless there is a strong, documented reason not to.
- Prefer smaller honest public APIs over larger unsound ones.
- Prefer a strict supported subset over wider unsound coverage. If one edge case would force a weaker public type across the whole API, keep the stricter model for the sound subset and document the unsupported remainder.
- Prefer zero-cost or near-zero-cost interop. New runtime bridge modules need proof that they solve a real problem that externals cannot solve.
- Separate exact SDK bindings from package-authored support surface. That surface is allowed, but it must be clearly labeled as package-added surface in docs.
- Do not flatten branded SDK values into JSON or plain records if the runtime value is actually a class instance.

## What Good Looks Like

- A ReScript user can move between upstream JS docs and this package without losing the mapping.
- The public `.resi` files describe the real contract instead of hiding uncertainty behind fake generics.
- Literal unions, enums, discriminated unions, and nullish values are modeled with current ReScript interop features instead of ad hoc strings and booleans.
- Open foreign data stays open until the caller classifies it.
- Compromises are narrow, explicit, and documented in `docs/TYPE_FIDELITY.md`.
- Unsupported or partially supported upstream cases are recorded explicitly instead of weakening the sound subset to make coverage numbers look better.
- Public package-added APIs do not masquerade as upstream SDK exports.

## ReScript Representation Rules

- Use `@module`, `@scope`, `@send`, `@get`, `@set`, `@new`, `@variadic`, `@return(...)`, `@as`, `@tag`, and `@unboxed` before inventing package-authored APIs.
- Use records for fixed config objects and fixed payload shapes.
- Use `dict<'a>` only for true open dictionaries with uniform value type.
- Use opaque `type t` for classes, branded values, iterators, and external objects with behavior.
- Use `@send` for instance methods and `@get` or `@set` for properties.
- Use variants with `@as` for string and number literal unions.
- Use `@tag` plus inline-record variants for discriminated unions when the runtime shape actually matches.
- Use `@unboxed` only when the runtime representation is exact and the unboxed cases remain semantically honest.
- Use `option<'a>` only for `undefined` or omitted record fields.
- Use `Nullable.t<'a>` or another honest nullish representation for `null` or `null | undefined`.
- Use `@return(nullable)` only when the JS contract truly is "nullable return" and the emitted behavior has been checked. Do not use it as a shortcut around unclear nullish semantics.
- Use `unknown` for untrusted foreign values.
- Do not use free type variables or `'a` as fake type safety for foreign data.
- Keep public generics only when the JS API actually preserves the type parameter semantically.
- Split overloads into multiple externals when that is what honesty requires.
- Use subtyping or upcasts only for real JS hierarchies or real shared contracts, and only when it materially improves the public API.

## Public Boundary Rules

- Every public value in a `.resi` file must be either exact, explicitly checked, or explicitly documented as open.
- Every public `unknown` must be intentional. If you add one, explain why a closed ReScript type would lie.
- Every new public `unknown` must name its owning boundary class in code comments or docs:
  - foreign input
  - foreign output
  - event payload
  - runtime classifier
  - codec boundary
- Every public `%identity`, `Obj.magic`, or `%raw` is a suspect boundary until proven otherwise.
- Never export unchecked downcasts. Prefer `isInstance` plus `fromUnknown`.
- Do not expose raw payloads as Surreal values unless they have actually been classified as Surreal values.
- Do not turn a closed upstream object into `dict<unknown>` because the field list felt tedious to maintain.
- Do not turn a closed upstream union into `string` because the variant looked inconvenient.
- Do not widen a public API to `unknown` when the real problem is one missing overload, one nullable field, or one dynamic leaf value.
- Do not expose `*Raw` functions publicly unless one of these is true:
  - the upstream SDK itself exposes that exact raw concept
  - the raw form is required to preserve the exact upstream contract
  - the typed surface cannot be expressed honestly without also exposing the raw form
- If a typed function and a `*Raw` function both exist publicly, the docs must explain why both are necessary.

## Generic Translation Rules

- Do not translate a TypeScript generic into ReScript `'a` unless the runtime preserves that type parameter semantically.
- If the JS runtime returns data whose shape depends on query text, event names, callbacks, schema, or caller convention, default to a checked boundary, not fake polymorphism.
- Value-dependent APIs are not ordinary polymorphism. If the callback type depends on a runtime string or discriminant, either:
  - split the API into narrower functions
  - generate a stronger typed layer from an authoritative source
  - keep one honest open boundary and document it
- Never use `'a`, `'value`, `'payload`, or similar type variables to hide untyped JS data.
- Never replace a hard generic problem with `array<unknown>` across the whole API if only one leaf is dynamic.

## Type Fidelity Policy

`docs/TYPE_FIDELITY.md` is mandatory and current. Any gap between upstream expressivity and ReScript expressivity must be recorded there.

Every fidelity gap entry must say:

- what strict supported subset the package chose
- what upstream cases remain unsupported or intentionally open
- why modeling those cases more exactly is not currently sound in ReScript

Good compromises:

- expose the narrowest honest boundary
- keep unsafe recovery internal
- force caller-side narrowing when runtime information is genuinely dynamic
- explain why the compromise exists
- keep the sound subset precise even if that means leaving edge cases unsupported

Bad compromises:

- replacing a hard type with `string`
- replacing a literal union with `bool`
- replacing a structured object with `dict<unknown>`
- replacing an impossible generic with `'a`
- replacing a dynamic boundary with a fake precise type
- widening a mostly-modelable surface because a rare edge case was harder to model soundly

When upstream uses keyed variadic tuples, mapped types, conditional types, runtime-generated members, or meta-class behavior, do one of these:

- bind a smaller honest surface
- generate a more specific API from a stronger source of truth
- keep the surface internal until it can be represented honestly

## AI Fraud And Failure Modes

The following are fraud in a public binding repository:

- Claiming a 1:1 binding while exporting package-authored APIs as if they were upstream SDK exports.
- Silently replacing an unrepresentable TypeScript type with `string`, `Js.Json.t`, `dict<unknown>`, `option<'a>`, `'a`, or `unit`.
- Translating TypeScript generics into ML polymorphism without proving that the runtime preserves the parameter.
- Merging incompatible overloads into a vague catch-all signature.
- Hiding `null`, `undefined`, omission, or thrown errors behind a single vague abstraction.
- Exporting unchecked `Obj.magic`, `%identity`, or `%raw` paths because proper modeling was harder.
- Calling a change "zero-cost" without inspecting the emitted JS on a representative example.
- Calling a change "sound" while leaving `docs/TYPE_FIDELITY.md` or `docs/TYPE_SOUNDNESS_AUDIT.md` stale.
- Verifying only compilation and not runtime behavior, emitted JS shape, or public surface behavior.
- Adding convenience APIs that change semantics and then documenting them as if the SDK worked that way.
- Trusting AI-generated bindings, including your own, without diffing against `surrealdb.d.ts` and runtime behavior.

## `%identity`, `Obj.magic`, And `%raw`

Treat these as hazardous materials.

Acceptable uses are narrow and internal:

- checked runtime casts after `instanceof` or equivalent proof
- honest upcasts to a real shared supertype
- explicit conversion into `unknown` at a foreign boundary
- JS syntax that standard externals cannot represent, after emitted JS inspection

Unacceptable uses:

- public unchecked downcasts
- fake generic recovery
- hiding nullability differences
- broad public escape hatches
- replacing missing modeling work
- public conversion that manufactures a more precise type than the runtime proved

If you add a new public boundary of this kind, update `docs/TYPE_SOUNDNESS_AUDIT.md`.

## Workflow For Any Binding Change

1. Read the relevant upstream docs and the relevant slice of `surrealdb.d.ts`.
2. Inventory the exact exports, constructors, methods, properties, literal unions, events, errors, and value classes involved.
3. Decide what is exact SDK surface and what is package-authored support surface.
4. Design the public `.resi` shape before or alongside implementation.
5. Implement with standard ReScript interop features first.
6. Inspect emitted JS for representative tricky call sites.
7. Add or update tests for public shape and runtime behavior.
8. Update docs for fidelity gaps and soundness boundaries.

## ReScript Build Integrity

- `.res` and `.resi` files are the source of truth.
- Tracked `.mjs` files are generated output only.
- Never hand-edit generated `.mjs` files.
- Do not use `rescript watch` as the agent workflow.
- After each change, run the repo build command and read the actual build result.

## Process Authority

The detailed process lives in these files:

- `docs/RELEASE_BLOCKERS.md`
- `docs/process/BINDING_PROOF_PROCESS.md`
- `docs/process/VERSIONING_CONTRACT.md`
- `docs/process/SOURCE_COMMENT_CONTRACT.md`
- `docs/process/SOUNDNESS_COVERAGE.md`
- `docs/process/README_CONTRACT.md`
- `docs/audits/TEMPLATE.md`
- `docs/audits/PERIODIC_TEMPLATE.md`
- `docs/process/VERSIONING_CONTRACT.md`
- `docs/SOUNDNESS_MATRIX.md`

Follow those files as the concrete workflow and artifact contract.

If `docs/RELEASE_BLOCKERS.md` contains any open blocker, breadth work does not count as progress. Do not add new public surface, support-surface breadth, docs polish, or coverage-growth-only tests until the open blockers are closed in code and proved through direct binding evidence inside this repo.

Do not recreate throwaway consumer apps, packed-tarball consumer fixtures, or external-project harnesses as the package's proof mechanism. User-reported consumer failures are bug reports to objectify into direct binding defects and repo-owned tests, not a prompt to build fake consumers inside the binding repo.

ReScript-authored tests must use `rescript-vitest` as the test framework boundary. Do not replace it with a repo-owned Vitest DSL built from direct raw Vitest externals.
ReScript-authored tests stay in `.res` and use native `async`/`await`. Do not add hand-written `.mjs` test stubs, fixture modules, or promise shims to simulate SDK behavior.

The process docs define:

- required audit artifacts
- chain-of-evidence rules
- role separation
- adversarial review
- soundness coverage expectations
- README scope
- periodic audit triggers
- commit attribution for materially Codex-assisted work

## Non-Negotiable Acceptance Gates

Do not consider binding work complete until all applicable items below are true:

- `docs/RELEASE_BLOCKERS.md` has no still-open blocker touched by the change.
- `npm run build` passes.
- `npm test` passes, unless the user explicitly asked for docs-only work and no binding code changed.
- Any new or changed public `unknown` is justified in `docs/TYPE_FIDELITY.md` or `docs/TYPE_SOUNDNESS_AUDIT.md`.
- Any new or changed public `%identity`, `Obj.magic`, or `%raw` site is justified in `docs/TYPE_SOUNDNESS_AUDIT.md`.
- Any public `.resi` change has a matching surface test or runtime test at the affected boundary.
- If a public `*Raw` function was added or kept, the reason is documented.
- If upstream `surrealdb.d.ts` changed, the changed declarations were diffed against the affected `.resi` files.
- If docs say the package is passing, the package must actually be passing in the current workspace.
- A current audit report exists for every non-trivial public binding change.
- The audit report contains an adversarial section and a written verdict.
- The evidence chain is sufficient for a later maintainer to reproduce the reasoning.
- Affected public boundary modules include the required rationale and coverage comments from `docs/process/SOURCE_COMMENT_CONTRACT.md`.

## Repo-Specific Maintenance Checklist

- Keep `src/Surrealdb.res` and `src/Surrealdb.resi` thin.
- When public API shape changes, update `README.md`.
- When a compromise changes, update `docs/TYPE_FIDELITY.md`.
- When public `unknown`, `%identity`, decode boundaries, or escape hatches change, update `docs/TYPE_SOUNDNESS_AUDIT.md`.
- When package support surface is added around real SDK surface, document that it is package-added and not upstream exports.
- When the supported upstream SDK version changes, update `peerDependencies`, docs, and any affected tests.
- Any user-facing package change requires a changeset.
- Keep `docs/TYPE_SOUNDNESS_AUDIT.md` synchronized with the actual current public `.resi` surface. Stale debt inventories are defects.
- Keep `docs/audits/` current for major binding decisions. Missing or stale audit records are defects.
- Keep `README.md` aligned with `docs/process/README_CONTRACT.md`. README is the human landing page, not an agent notebook.

## Verification Requirements

Compilation is necessary and insufficient.

For binding work, verification means:

- run `npm run build`
- run `npm test`
- inspect emitted JS for representative subtle externals
- verify runtime-branded classes with construction, property access, method calls, and classification
- verify both presence and absence cases for nullish and optional boundaries
- verify error classification on real thrown values or realistic constructed failures
- verify unsubscribe, cleanup, or iterator behavior on event and stream surfaces
- verify that public typed APIs and any public `*Raw` companion APIs still agree with each other

If a change affects the public surface but does not change tests or docs, assume the work is incomplete until proven otherwise.

## Tests This Repo Expects

- surface tests for public API shape
- runtime tests for bound constructors, methods, and properties
- live tests for actual SurrealDB behavior where the binding could otherwise lie
- round-trip tests for typed value classes and codecs
- explicit tests around open boundaries such as `unknown`, nullish values, frames, event payloads, and error payloads

Add a test where the risk lives. Do not rely on unrelated coverage.

## When To Generate Instead Of Hand-Bind

Prefer hand-written bindings when:

- the surface is small
- the fidelity decisions are subtle
- runtime classes, error types, and nullability matter more than raw volume

Prefer generation when:

- the surface is large and repetitive
- the upstream source of truth is mechanical and authoritative
- manual maintenance would mostly copy metadata

Generation does not remove review obligations. Generated code still needs human review for:

- nullability
- overload splits
- literal unions
- runtime classes
- public escape hatches
- emitted JS shape

If generation depends on fragile upstream tooling, pin the supported upstream version and document the limitation.

If consumers should not need the generator at build time, commit generated artifacts.

## Benchmark Patterns Worth Copying

- `@rescript/react`
  - close to upstream React
  - low-level externals
  - explicit comments where perfect fidelity is awkward
- `rescript-webapi`
  - strong top-level namespace
  - documented subtyping model
  - implementation inheritance only where it matches the platform
- `rescript-nodejs`
  - explicit goals and non-goals
  - zero-cost bias
  - subtyping only where benefit is substantial
- `@glennsl/rescript-fetch`
  - uses newer language features to improve ergonomics without abandoning low-level interop
- `rescript-vitest`
  - compatibility across compiler modes
  - explicit binding context
  - ergonomic package APIs that still map back to upstream Vitest
- `rescript-edgedb`
  - generate from a stronger source of truth when available
  - keep generated artifacts in source when that improves consumer reliability
- `rescript-material-ui`
  - generation is viable for huge surfaces
  - generator drift, upstream doc inaccuracies, and version pinning must be acknowledged openly

## Maintenance Reality

Bindings rot when they are vague, undocumented, and too large to reason about.

A public industrial-grade binding stays maintainable by doing the opposite:

- narrow, explicit public contracts
- strong source-of-truth discipline
- clear version support
- explicit type-fidelity notes
- explicit soundness audits
- good tests at real boundaries

The correct long-term strategy is not "be more flexible". It is "be more honest".

## Research Anchors

- ReScript external interop: https://rescript-lang.org/docs/manual/external
- ReScript JS function interop and `unknown` guidance: https://rescript-lang.org/docs/manual/bind-to-js-function/
- ReScript JS object interop: https://rescript-lang.org/docs/manual/bind-to-js-object/
- ReScript null and undefined interop: https://rescript-lang.org/docs/manual/null-undefined-option/
- ReScript customizable variants and unboxed interop: https://rescript-lang.org/blog/improving-interop/
- ReScript 11 release notes: https://rescript-lang.org/blog/release-11-0-0/
- ReScript uncurried mode: https://rescript-lang.org/blog/uncurried-mode
- SurrealDB JavaScript SDK docs: https://surrealdb.com/docs/sdk/javascript
- `@rescript/react`: https://github.com/rescript-lang/rescript-react
- `rescript-webapi`: https://github.com/TheSpyder/rescript-webapi
- `rescript-nodejs`: https://github.com/TheSpyder/rescript-nodejs
- `rescript-vitest`: https://github.com/cometkim/rescript-vitest
- `rescript-edgedb`: https://github.com/zth/rescript-edgedb
- `rescript-material-ui`: https://rescript-material-ui.cca.io/docs/introduction/
- AI bindings writer discussion and examples: https://forum.rescript-lang.org/t/rescript-bindings-writer-agent-skills/7106
- Binding style discussion: https://forum.rescript-lang.org/t/how-do-you-writing-bindings-today/5059
- Method and property binding guidance: https://forum.rescript-lang.org/t/trouble-creating-js-bindings/1627
- Dynamic meta-class limitation example: https://forum.rescript-lang.org/t/binding-to-meta-classes-types-whose-properties-are-defined-at-runtime/2998
- Low-level binding trade-off discussion: https://forum.rescript-lang.org/t/rfc-new-promise-binding/963
- Maintenance reality for stale bindings: https://forum.rescript-lang.org/t/why-are-the-bindings-for-most-libraries-outdated/5552
- Zero-cost fetch discussion: https://forum.rescript-lang.org/t/ann-zero-cost-fetch-bindings-glennsl-rescript-fetch/3691
