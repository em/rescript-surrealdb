// src/bindings/Surrealdb_Equals.res — SurrealDB equality function.
// Concern: bind the public SDK function that compares two SurrealDB values with
// the same equality semantics used by the runtime value classes.
@module("surrealdb") external values: (Surrealdb_JsValue.t, Surrealdb_JsValue.t) => bool = "equals"
