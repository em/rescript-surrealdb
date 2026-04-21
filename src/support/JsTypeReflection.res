// src/bindings/JsTypeReflection.res — JavaScript reflection boundary.
// Concern: expose a safe `instanceof` wrapper for SDK class-instance checks.
// Source: node_modules/rescript-nodejs/src/internal/Internal__JsTypeReflection.res —
// wrap `instanceof` in try/catch and return false when the right-hand operand is
// not a valid constructor.
@module("./Surrealdb_Interop.js")
external instanceOfClassRaw: ('instance, 'class_) => bool = "instanceOfClass"

let instanceOfClass = (~instance, ~class_) => instanceOfClassRaw(instance, class_)
