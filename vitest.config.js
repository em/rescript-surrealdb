export default {
  test: {
    include: ["tests/**/*_test.mjs"],
    exclude: [
      "tests/SurrealdbTestContext.mjs",
      "tests/support/**",
    ],
    environment: "node",
    fileParallelism: false,
    globalSetup: ["./tests/support/globalSetup.mjs"],
    setupFiles: ["./tests/support/websocketSetup.mjs"],
    coverage: {
      provider: "v8",
      include: ["src/**/*.mjs"],
      thresholds: {
        statements: 80,
        branches: 80,
        functions: 80,
        lines: 80,
      },
    }
  }
}
