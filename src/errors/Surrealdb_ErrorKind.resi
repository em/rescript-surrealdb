type t =
  | Validation
  | Configuration
  | Thrown
  | Query
  | Serialization
  | NotAllowed
  | NotFound
  | AlreadyExists
  | Connection
  | Internal
  | Raw(string)

let validation: t
let configuration: t
let thrown: t
let query: t
let serialization: t
let notAllowed: t
let notFound: t
let alreadyExists: t
let connection: t
let internal: t
let all: array<t>
let fromString: string => t
let toString: t => string
