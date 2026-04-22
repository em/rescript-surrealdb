const message = [
  "Local publishing is disabled for this repository.",
  "Use Changesets and merge the release PR opened by .github/workflows/release.yml.",
  "GitHub Actions trusted publishing runs npm run release:ci.",
]

console.error(message.join("\n"))
process.exit(1)
