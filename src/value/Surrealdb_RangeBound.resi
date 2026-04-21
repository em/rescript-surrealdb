type included<'a>
type excluded<'a>
type includedCtor
type excludedCtor

type t<'a> =
  | Included(included<'a>)
  | Excluded(excluded<'a>)

let includeValue: 'a => included<'a>
let excludeValue: 'a => excluded<'a>
let includedCtor: includedCtor
let excludedCtor: excludedCtor
let includedValueOf: included<'a> => 'a
let excludedValueOf: excluded<'a> => 'a
let included: 'a => t<'a>
let excluded: 'a => t<'a>
let value: t<'a> => 'a
let toUnknown: t<'a> => unknown
let isIncludedInstance: unknown => bool
let isExcludedInstance: unknown => bool
let fromUnknown: unknown => option<t<'a>>
