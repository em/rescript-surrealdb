export default {
  test: {
    include: ["tests/connection/SurrealdbSessionSurface_test.mjs"],
    exclude: ["tests/TestRuntime.mjs", "tests/SurrealdbTestContext.mjs", "tests/support/**"],
    environment: "node",
    fileParallelism: false,
    globalSetup: ["./tests/support/globalSetup.mjs"],
  },
}
