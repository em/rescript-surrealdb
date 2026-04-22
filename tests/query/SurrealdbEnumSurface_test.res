open TestRuntime

describe("SurrealDB enum helpers", () => {
  test("error kinds round-trip through the closed variant surface", () => {
    (
      Surrealdb_ErrorKind.all->Array.map(kind => kind->Surrealdb_ErrorKind.toString),
      [
        "Validation",
        "Configuration",
        "Thrown",
        "Query",
        "Serialization",
        "NotAllowed",
        "NotFound",
        "AlreadyExists",
        "Connection",
        "Internal",
        "FutureKind",
      ]->Array.map(Surrealdb_ErrorKind.fromString),
      Surrealdb_ErrorKind.Raw("FutureKind")->Surrealdb_ErrorKind.toString,
    )
    ->Expect.expect
    ->Expect.toEqual((
      [
        "Validation",
        "Configuration",
        "Thrown",
        "Query",
        "Serialization",
        "NotAllowed",
        "NotFound",
        "AlreadyExists",
        "Connection",
        "Internal",
      ],
      [
        Surrealdb_ErrorKind.Validation,
        Surrealdb_ErrorKind.Configuration,
        Surrealdb_ErrorKind.Thrown,
        Surrealdb_ErrorKind.Query,
        Surrealdb_ErrorKind.Serialization,
        Surrealdb_ErrorKind.NotAllowed,
        Surrealdb_ErrorKind.NotFound,
        Surrealdb_ErrorKind.AlreadyExists,
        Surrealdb_ErrorKind.Connection,
        Surrealdb_ErrorKind.Internal,
        Surrealdb_ErrorKind.Raw("FutureKind"),
      ],
      "FutureKind",
    ))
  })

  test("query outputs parse and stringify across every public case", () => {
    (
      [
        Surrealdb_Output.None,
        Surrealdb_Output.Null,
        Surrealdb_Output.Diff,
        Surrealdb_Output.Before,
        Surrealdb_Output.After,
      ]->Array.map(Surrealdb_Output.toString),
      [
        "none",
        "null",
        "diff",
        "before",
        "after",
        "  AFTER  ",
        "invalid",
      ]->Array.map(Surrealdb_Output.parse),
    )
    ->Expect.expect
    ->Expect.toEqual((
      ["none", "null", "diff", "before", "after"],
      [
        Some(Surrealdb_Output.None),
        Some(Surrealdb_Output.Null),
        Some(Surrealdb_Output.Diff),
        Some(Surrealdb_Output.Before),
        Some(Surrealdb_Output.After),
        Some(Surrealdb_Output.After),
        None,
      ],
    ))
  })
})
