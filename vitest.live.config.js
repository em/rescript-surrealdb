export default {
  test: {
    include: [
      "tests/connection/*_test.mjs",
      "tests/api/SurrealdbApiCompileSurface_test.mjs",
      "tests/query/SurrealdbOperationCoverage_test.mjs",
      "tests/live/SurrealdbLiveSurface_test.mjs",
    ],
    exclude: [
      "tests/SurrealdbTestContext.mjs",
      "tests/support/**",
    ],
    environment: "node",
    fileParallelism: false,
    globalSetup: ["./tests/support/globalSetup.mjs"],
    setupFiles: ["./tests/support/websocketSetup.mjs"],
  },
}
