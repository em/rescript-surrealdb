type t

let make: unit => t
let subscribe: (t, string, array<unknown> => unit) => unit => unit
let subscribeFirst: (t, array<string>) => promise<array<unknown>>
let publish: (t, string, array<unknown>) => unit
