// src/bindings/Surrealdb_Equals.res — SurrealDB equality helper.
// Concern: bind the public SDK helper that compares two SurrealDB values with
// the same equality semantics used by the runtime value classes.
@module("surrealdb") external values: (unknown, unknown) => bool = "equals"
