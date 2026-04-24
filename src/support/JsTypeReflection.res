// Concern: expose a safe `instanceof` boundary for SDK class-instance checks.
// Source: node_modules/rescript-nodejs/src/internal/Internal__JsTypeReflection.res —
// wrap `instanceof` in try/catch and return false when the right-hand operand is
// not a valid constructor.
// Boundary: JavaScript reflection at class-classification seams.
// Why this shape: a failed right-hand operand must return `false`, not throw,
// because classifier modules use this boundary to decide whether a foreign value
// matches an SDK runtime class.
// Coverage: tests/SurrealdbBoundaryCoverage_test.res and
// tests/value/SurrealdbValueSurface_test.res exercise the affected runtime
// classifiers.
@module("./Surrealdb_Interop.js")
external instanceOfClassRaw: ('instance, 'class_) => bool = "instanceOfClass"

let instanceOfClass = (~instance, ~class_) => instanceOfClassRaw(instance, class_)
