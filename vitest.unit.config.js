export default {
  test: {
    include: ["tests/**/*_test.mjs"],
    exclude: [
      "tests/SurrealdbTestContext.mjs",
      "tests/support/**",
      "tests/connection/**",
      "tests/api/SurrealdbApiCompileSurface_test.mjs",
      "tests/query/SurrealdbOperationCoverage_test.mjs",
      "tests/query/SurrealdbQueryVariantCoverage_test.mjs",
      "tests/live/SurrealdbLiveSurface_test.mjs",
    ],
    environment: "node",
    fileParallelism: false,
  },
}
