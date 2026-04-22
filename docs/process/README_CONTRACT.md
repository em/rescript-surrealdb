# README Contract

## Purpose

`README.md` is the package landing page on GitHub and npm.

Its job is to help a human reader decide whether the package is relevant, install it quickly, and find the next example or module they need.

## Primary Reader

Assume the reader has not seen the repo before and wants fast answers to these questions:

- what package is this
- what upstream package does it bind
- what version line does it support
- how do I install it
- what does the smallest useful example look like
- where do I go next for examples or modules

## Required Shape

README should usually present information in this order:

1. package identity and one-sentence description
2. install and compatibility notes
3. smallest useful example
4. high-level package guide
5. examples and upstream docs
6. local development commands
7. a short release note if the release path matters to contributors

## What README Must Cover

- what the package is
- what upstream package or packages it binds
- the supported upstream version or package line
- installation, including peer dependencies when relevant
- a real example near the top
- the main modules, subpaths, or task areas
- where to find more examples or upstream reference docs
- the main local build and test commands

## What README Must Not Become

- an internal process manual
- an audit log
- a proof record
- a changelog
- a copy of `AGENTS.md`
- a release playbook
- an AI authorship statement
- a list of internal repo rules

Do not require readers to learn the repo's maintenance process before they can install or use the package.

## Style Rules

- write for package users first
- make install and usage visible without scrolling through maintainer material
- prefer one working example over abstract claims
- mirror upstream package names and terminology
- keep module descriptions short and task-focused
- keep maintainer-only notes brief and late
- use absolute GitHub links for files that are not shipped in the npm tarball

## Maintainer Notes

Maintainer or contributor links are allowed at the end of the README when they help someone continue deeper work.

They are optional. They are not the main content of the page.

## Source Of Truth Rule

The binding code and public `.resi` files define the package interface.

The README explains that interface at a high level. It does not replace the interface files or the deeper docs.

## Required Maintenance Rule

When the supported upstream version, installation story, public package shape, or example path changes in a user-visible way, update `README.md`.
