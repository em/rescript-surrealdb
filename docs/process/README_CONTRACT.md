# README Contract

## Purpose

`README.md` is for humans.

It is the GitHub landing page and package front page. It explains what the package is, how to install it, what it covers, and how it is maintained.

It is not the place for agent-only rules, full design rationale, or exhaustive proof records.

## What README Must Cover

- what the package is
- what upstream package it binds
- installation
- high-level package shape
- how to run the package locally
- release basics
  - whether publishing is local or CI-owned
  - if CI-owned, that local shells do not publish
- the maintenance model:
  - Codex-assisted binding authorship
  - Codex co-author attribution in commit history for materially assisted changes
  - documented proof process
  - adversarial audits
  - soundness coverage and living matrix
- links to the deeper docs

## What README Must Not Become

- an internal design notebook
- an audit log
- a dump of every fidelity gap
- a copy of `AGENTS.md`
- a duplicate of the process docs

## Style Rules

- keep it succinct
- optimize for first-time human readers
- keep the package story stable even as internals evolve
- link out instead of inlining large maintainer process details

## Source Of Truth Rule

The binding code and public `.resi` files are the source of truth for the package interface.

The README is the landing page that explains that interface and links to the process that keeps it trustworthy.

## Required Maintenance Rule

When the maintainer model, supported upstream version, or public package shape changes in a user-visible way, update `README.md`.
