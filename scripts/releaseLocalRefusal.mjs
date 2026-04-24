const message = [
  "Local publishing is disabled for this repository.",
  "Changesets and .github/workflows/release.yml handle versioning, tagging, and publishing directly on main.",
  "GitHub Actions trusted publishing runs npm run release:ci.",
]

console.error(message.join("\n"))
process.exit(1)
