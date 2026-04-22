---
"rescript-surrealdb": patch
---

Fix Node 20 runtime compatibility after the `1.0.0` release.

- replace `Array.fromAsync` with a Node 20-safe async iterable collector
- stabilize live WebSocket verification on GitHub Actions
