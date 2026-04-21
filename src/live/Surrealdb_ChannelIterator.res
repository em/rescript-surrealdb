// src/bindings/Surrealdb_ChannelIterator.res — SurrealDB ChannelIterator binding.
// Concern: bind the exported async-iterator utility from the surrealdb SDK.
type t<'value>
type result<'value>

@module("surrealdb") @new external make: unit => t<'value> = "ChannelIterator"
@module("surrealdb") @new external makeWithCleanup: (unit => unit) => t<'value> = "ChannelIterator"

@send external next: t<'value> => promise<result<'value>> = "next"
@send external return_: t<'value> => promise<result<'value>> = "return"
@send external throwRaw: (t<'value>, unknown) => promise<result<'value>> = "throw"
@send external submit: (t<'value>, 'value) => unit = "submit"
@send external cancel: t<'value> => unit = "cancel"

@get external done: result<'value> => bool = "done"
@get external valueRaw: result<'value> => Nullable.t<'value> = "value"

external asAsyncIterable: t<'value> => Surrealdb_AsyncIterable.t<'value> = "%identity"

let value = result =>
  result->valueRaw->Nullable.toOption

let throw_ = (iterator, error) =>
  iterator->throwRaw(error)
