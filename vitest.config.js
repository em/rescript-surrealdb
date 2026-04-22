export default {
  test: {
    include: ["tests/**/*.mjs"],
    exclude: [
      "tests/TestRuntime.mjs",
      "tests/SurrealdbTestContext.mjs",
      "tests/support/**",
    ],
    environment: "node",
    fileParallelism: false,
    globalSetup: ["./tests/support/globalSetup.mjs"],
    coverage: {
      provider: "v8",
      include: ["src/**/*.mjs"],
      thresholds: {
        statements: 50,
        branches: 50,
        functions: 50,
        lines: 50,
      },
    }
  }
}
