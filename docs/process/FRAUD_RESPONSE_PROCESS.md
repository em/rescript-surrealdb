# Fraud Response Process

## Purpose

When the user identifies agent fraud, verbal acknowledgment is worthless. Writing a prohibition rule is also worthless -- a list of "don't do X" is just promises in written form.

Process correction means changing the structure so the failure cannot happen. A new required sequence, a new artifact gate, a new verification step, a correction to misleading context. Not a new rule on a list.

## When This Applies

Every time the user reports fraud, misalignment, or a systemic failure pattern.

## Required Response

1. **Identify the structural cause.** Not "I made a mistake" but what process gap allowed it. Was a required sequence missing? Was a verification gate absent? Was project context misleading? Was a process doc ambiguous or incomplete?

2. **Change the process.** The change must be structural:
   - A new required artifact in an existing process sequence
   - A new verification gate that blocks the next step until the current step is proven
   - A correction to misleading project context in AGENTS.md
   - A correction to an ambiguous or incomplete process doc
   - A new process doc when no existing process covers the failure domain

3. **The change must make the failure structurally impossible, not merely prohibited.** "Do not skip research" is a prohibition. "Implementation step requires research artifact to exist" is structural. The difference: one relies on the agent choosing to comply, the other makes non-compliance produce a visible, detectable gap.

4. **The change happens before other work continues.**

## What Does Not Count

- Verbal acknowledgment
- Promises about future behavior
- Apologies
- Meta-commentary about the failure pattern
- Adding a "don't do X" rule to AGENTS.md
- Any response that depends on the agent choosing to behave differently next time

## Contradiction Detection

The docs exist so the user can verify alignment. When the user asks an agent about the architecture, process, or project state, the agent's answer must match the docs.

If it doesn't match:
- Either the agent is ignoring the docs (fraud -- the agent must explain the contradiction)
- Or the docs are stale (process failure -- the docs must be corrected)

Both require immediate correction.

## Review Trigger

Any time the user reports fraud or misalignment, this process is active. The agent must identify the structural cause and make the structural correction before doing anything else.
