export default {
  test: {
    include: ["tests/**/*.mjs"],
    exclude: [
      "tests/TestRuntime.mjs",
      "tests/SurrealdbTestContext.mjs",
      "tests/support/**",
      "tests/connection/**",
    ],
    environment: "node",
    fileParallelism: false,
  },
}
