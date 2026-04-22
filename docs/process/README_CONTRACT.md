# README Contract

## Purpose

`README.md` is the human landing page for the repository and the npm package.

Its first job is to help a new user decide whether the package is relevant and how to start using it.

## Primary Reader

Assume the reader has just opened the GitHub repo or npm page and wants fast answers to these questions:

- what is this package
- what upstream package does it bind
- how do I install it
- what does basic usage look like
- what are the main modules
- how do I build and test it locally

## Required Shape

README should usually present information in this order:

1. package identity and one-sentence description
2. install
3. smallest useful example
4. high-level package layout or main modules
5. local development and verification
6. release basics
7. links to deeper maintainer docs

## What README Must Cover

- what the package is
- what upstream package or packages it binds
- installation
- a real usage example near the top
- high-level package shape
- how to run the package locally
- release basics
  - whether publishing is local or CI-owned
  - if CI-owned, that local shells do not publish
- a brief maintenance note
  - Codex-assisted binding authorship
  - documented proof process
  - deeper audit and soundness docs live elsewhere

## What README Must Not Become

- an internal design notebook
- an audit log
- a process manual
- a proof record
- a list of repo policies
- a copy of `AGENTS.md`
- an AI status report

Do not lead with maintenance model, adversarial review, Codex attribution, or soundness process language before the reader has seen install and usage.

## Style Rules

- optimize for first-time human readers
- lead with the package, not the process
- use concrete examples instead of abstract claims
- keep module summaries high-level
- keep maintainer-process text brief and late
- link out instead of inlining long process details
- if a linked file is not shipped in the npm tarball, use an absolute GitHub link

## Source Of Truth Rule

The binding code and public `.resi` files are the source of truth for the package interface.

The README explains that interface at a high level. It does not replace the interface files or the process docs.

## Required Maintenance Rule

When the supported upstream version, public package shape, installation story, or maintainer workflow changes in a user-visible way, update `README.md`.
