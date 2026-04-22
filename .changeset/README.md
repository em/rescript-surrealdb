# Changesets

- Run `npm run changeset` for any user-facing package change.
- Commit the generated markdown file with the code change.
- The release workflow will turn pending changesets into the release PR and publish after that PR is merged.
- Do not run `npm publish` or `npm run release` locally.
- GitHub Actions owns npm publication and runs `npm run release:ci` through trusted publishing.
