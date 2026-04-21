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
    coverage: {
      provider: "v8",
      include: ["src/**/*.mjs"],
      exclude: ["src/Surrealdb.mjs"]
    }
  }
}
