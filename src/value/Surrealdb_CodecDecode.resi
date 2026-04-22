type error =
  | RejectedValue(unknown)

let decodeWithUnknown: (unknown, unknown => option<'value>) => result<'value, error>
