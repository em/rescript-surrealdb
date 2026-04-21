// src/bindings/Surrealdb_Value.res — SurrealDB value type.
// Concern: model the SurrealDB value type system as a ReScript closed variant,
// mirroring the Rust Value enum. The SDK returns typed class instances at runtime;
// this variant classifies them for exhaustive pattern matching.
// Source: Rust Value enum — None, Null, Bool, Number(Int|Float|Decimal), Strand,
// Duration, Datetime, Uuid, Table, Thing, Range, Geometry, File, Array(Vec<Value>),
// Object(BTreeMap<String, Value>).

type rec t =
  | None
  | Null
  | Bool(bool)
  | Int(int)
  | Float(float)
  | String(string)
  | FileRef(Surrealdb_FileRef.t)
  | Future(Surrealdb_Future.t)
  | Decimal(Surrealdb_Decimal.t)
  | Datetime(Surrealdb_DateTime.t)
  | Duration(Surrealdb_Duration.t)
  | Uuid(Surrealdb_Uuid.t)
  | Table(Surrealdb_Table.t)
  | RecordId(Surrealdb_RecordId.t)
  | RecordIdRange(Surrealdb_RecordIdRange.t)
  | StringRecordId(Surrealdb_StringRecordId.t)
  | Range(Surrealdb_Range.t)
  | Geometry(Surrealdb_Geometry.t)
  | Array(array<t>)
  | Object(dict<t>)
external asNullable: unknown => Nullable.t<unknown> = "%identity"
external asString: unknown => string = "%identity"
external asBool: unknown => bool = "%identity"
external asFloat: unknown => float = "%identity"
external asInt: unknown => int = "%identity"
external asArray: unknown => array<unknown> = "%identity"
external asDict: unknown => dict<unknown> = "%identity"

let classifyTypedValue = raw =>
  switch Surrealdb_RecordId.fromUnknown(raw) {
  | Some(value) => Some(RecordId(value))
  | None =>
    switch Surrealdb_RecordIdRange.fromUnknown(raw) {
    | Some(value) => Some(RecordIdRange(value))
    | None =>
      switch Surrealdb_StringRecordId.fromUnknown(raw) {
      | Some(value) => Some(StringRecordId(value))
      | None =>
        switch Surrealdb_DateTime.fromUnknown(raw) {
        | Some(value) => Some(Datetime(value))
        | None =>
          switch Surrealdb_Duration.fromUnknown(raw) {
          | Some(value) => Some(Duration(value))
          | None =>
            switch Surrealdb_Decimal.fromUnknown(raw) {
            | Some(value) => Some(Decimal(value))
            | None =>
              switch Surrealdb_Uuid.fromUnknown(raw) {
              | Some(value) => Some(Uuid(value))
              | None =>
                switch Surrealdb_Table.fromUnknown(raw) {
                | Some(value) => Some(Table(value))
                | None =>
                  switch Surrealdb_FileRef.fromUnknown(raw) {
                  | Some(value) => Some(FileRef(value))
                  | None =>
                    switch Surrealdb_Future.fromUnknown(raw) {
                    | Some(value) => Some(Future(value))
                    | None =>
                      switch Surrealdb_Range.fromUnknown(raw) {
                      | Some(value) => Some(Range(value))
                      | None =>
                        switch Surrealdb_Geometry.fromUnknown(raw) {
                        | Some(value) => Some(Geometry(value))
                        | None => None
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }

let rec fromUnknown: unknown => t = raw =>
  switch classifyTypedValue(raw) {
  | Some(value) => value
  | None =>
    switch typeof(raw) {
    | #undefined => None
    | #string => String(asString(raw))
    | #boolean => Bool(asBool(raw))
    | #number =>
      let n = asFloat(raw)
      if Math.floor(n) == n && n > -2147483648.0 && n < 2147483648.0 {
        Int(asInt(raw))
      } else {
        Float(n)
      }
    | #object =>
      if Nullable.isNullable(asNullable(raw)) {
        Null
      } else if Array.isArray(raw) {
        Array(asArray(raw)->Array.map(fromUnknown))
      } else {
        let result = Dict.make()
        asDict(raw)
        ->Dict.toArray
        ->Array.forEach(((key, value)) => result->Dict.set(key, fromUnknown(value)))
        Object(result)
      }
    | #bigint | #function | #symbol => None
    }
  }

let rec toText = (value: t): string =>
  switch value {
  | None => ""
  | Null => "null"
  | Bool(b) => b ? "true" : "false"
  | Int(n) => Int.toString(n)
  | Float(n) => Float.toString(n)
  | String(s) => s
  | FileRef(fileRef) => Surrealdb_FileRef.toString(fileRef)
  | Future(future) => Surrealdb_Future.toString(future)
  | Decimal(d) => Surrealdb_Decimal.toString(d)
  | Datetime(dt) => Surrealdb_DateTime.toISOString(dt)
  | Duration(d) => Surrealdb_Duration.toString(d)
  | Uuid(u) => Surrealdb_Uuid.toString(u)
  | Table(t) => Surrealdb_Table.name(t)
  | RecordId(rid) => Surrealdb_RecordId.toString(rid)
  | RecordIdRange(range) => Surrealdb_RecordIdRange.toString(range)
  | StringRecordId(rid) => Surrealdb_StringRecordId.toString(rid)
  | Range(range) => Surrealdb_Range.toString(range)
  | Geometry(geometry) => Surrealdb_Geometry.toString(geometry)
  | Array(items) => items->Array.map(toText)->Array.join(", ")
  | Object(entries) =>
    entries
    ->Dict.toArray
    ->Array.map(((key, value)) => `${key}: ${toText(value)}`)
    ->Array.join("; ")
  }

let rec toJSON = (value: t): JSON.t =>
  switch value {
  | None | Null => JSON.Encode.null
  | Bool(b) => JSON.Encode.bool(b)
  | Int(n) => JSON.Encode.int(n)
  | Float(n) => JSON.Encode.float(n)
  | String(s) => JSON.Encode.string(s)
  | FileRef(fileRef) => JSON.Encode.string(Surrealdb_FileRef.toString(fileRef))
  | Future(future) => JSON.Encode.string(Surrealdb_Future.toString(future))
  | Decimal(d) => JSON.Encode.string(Surrealdb_Decimal.toString(d))
  | Datetime(dt) => JSON.Encode.string(Surrealdb_DateTime.toISOString(dt))
  | Duration(d) => JSON.Encode.string(Surrealdb_Duration.toString(d))
  | Uuid(u) => JSON.Encode.string(Surrealdb_Uuid.toString(u))
  | Table(t) => JSON.Encode.string(Surrealdb_Table.name(t))
  | RecordId(rid) => JSON.Encode.string(Surrealdb_RecordId.toString(rid))
  | RecordIdRange(range) => JSON.Encode.string(Surrealdb_RecordIdRange.toString(range))
  | StringRecordId(rid) => JSON.Encode.string(Surrealdb_StringRecordId.toString(rid))
  | Range(range) => JSON.Encode.string(Surrealdb_Range.toString(range))
  | Geometry(geometry) => Surrealdb_Geometry.toJSON(geometry)
  | Array(items) => JSON.Encode.array(items->Array.map(toJSON))
  | Object(entries) =>
    let result = Dict.make()
    entries->Dict.toArray->Array.forEach(((key, value)) => result->Dict.set(key, toJSON(value)))
    JSON.Encode.object(result)
  }
