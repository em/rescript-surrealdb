// tests/TestRuntime.res — direct Vitest bindings for ReScript tests.
// Concern: register tests and fetch injected runtime configuration values.
@module("vitest")
external describe: (string, @uncurry (unit => unit)) => unit = "describe"

@module("vitest")
external test: (string, @uncurry (unit => unit)) => unit = "test"

@module("vitest")
external testAsync: (string, @uncurry (unit => promise<unit>)) => unit = "test"

@module("vitest")
external injectString: string => string = "inject"

module Expect = {
  type t<'value>

  @module("vitest")
  external expect: 'value => t<'value> = "expect"

  @send
  external toBe: (t<'value>, 'value) => unit = "toBe"

  @send
  external toEqual: (t<'value>, 'other) => unit = "toEqual"
}
