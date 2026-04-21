type t<'value>

let collect: t<'value> => promise<array<'value>>
let forEach: (t<'value>, 'value => unit) => promise<unit>
