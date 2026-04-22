# Bootstrap Soundness Repair Audit

## Claim

- subsystem: package-wide public boundary repair
- change: narrow fake precision at codec, error, value, range, and record-id boundaries into checked or explicitly open public surfaces
- boundary class: codec boundary, runtime classifier, error payload, range payload, record-id payload
- exact public surface affected:
  - `src/value/Surrealdb_CborCodec.resi`
  - `src/value/Surrealdb_ValueCodec.resi`
  - `src/errors/Surrealdb_ErrorPayload.resi`
  - `src/errors/Surrealdb_Error.resi`
  - `src/errors/Surrealdb_ServerError.resi`
  - `src/value/Surrealdb_RangeBound.resi`
  - `src/value/Surrealdb_RecordId.resi`
  - `src/value/Surrealdb_Value.resi`

## Upstream Evidence

### Official Docs

- URL: https://surrealdb.com/docs/sdk/javascript
  - relevant excerpt or summary: the JavaScript SDK exposes branded runtime classes and evented/query surfaces that the binding must preserve honestly.
- URL: https://surrealdb.com/docs/sdk/javascript/core/data-types
  - relevant excerpt or summary: `RecordId`, `Range`, `DateTime`, `Duration`, `Decimal`, `Uuid`, `Table`, and geometry values are runtime data types, not plain JSON.

### Declaration Evidence

- file: `node_modules/surrealdb/dist/surrealdb.d.ts`
  - relevant signature:
    - line 136: `Duration extends Value`
    - line 339: `DateTime extends Value`
    - line 491: `Decimal extends Value`
    - line 670: `Geometry extends Value`
    - line 868: `Range$1<Beg, End> extends Value`
    - line 895: `Table<Tb extends string = string> extends Value`
    - line 912: `Uuid extends Value`
    - line 956: `RecordId<Tb extends string = string, Id extends RecordIdValue = RecordIdValue> extends Value`
    - line 983: `RecordIdRange<Tb extends string = string, Id extends RecordIdValue = RecordIdValue> extends Value`

### Runtime Evidence

- command or probe: `NOT RUN in this documentation retrofit`
- result: this bootstrap audit is a retroactive record anchored to current declarations, source files, and targeted test inventory; the next code-changing audit must refresh runtime proof directly.

## Local Representation

- affected files:
  - `src/value/Surrealdb_CborCodec.resi`
  - `src/value/Surrealdb_ValueCodec.resi`
  - `src/value/Surrealdb_CodecDecode.resi`
  - `src/errors/Surrealdb_ErrorPayload.resi`
  - `src/errors/Surrealdb_ServerError.resi`
  - `src/value/Surrealdb_RangeBound.resi`
  - `src/value/Surrealdb_RecordId.resi`
  - `src/value/Surrealdb_Value.resi`
- chosen ReScript shape:
  - codec decode stays open at `unknown` and typed recovery goes through `decodeWith`
  - error payloads classify into `Surrealdb_ErrorPayload.t` instead of pretending they are always Surreal values
  - range bounds classify through `Surrealdb_BoundValue.t`
  - record IDs expose a package-owned `idValue` union instead of raw unknown access
  - mixed runtime payloads classify through `Surrealdb_Value.t`, with unsupported foreign cases remaining explicit

## Alternatives Considered

### Alternative 1

- representation: keep fake generic decode and recovery APIs on public codec surfaces
- why rejected: a codec cannot prove the final ReScript type. Public typed decode without a caller-supplied classifier lies about the boundary.

### Alternative 2

- representation: expose raw `unknown` or unchecked casts for range bounds, record-id IDs, and error payloads
- why rejected: that pushes unsound recovery into the public API and leaves later maintainers no local proof of what is actually supported.

## Adversarial Questions

- question: does `Surrealdb_Value.t` itself over-claim exactness for foreign payloads
- evidence-based answer: it is documented in `docs/TYPE_FIDELITY.md` as a package classifier, not a direct SDK export. Unsupported foreign `bigint`, `function`, and `symbol` values remain explicit instead of disappearing.

- question: why not expose raw record-id payloads as `unknown`
- evidence-based answer: the current binding already knows the supported runtime ID shapes and exposes them through `Surrealdb_RecordId.idValue`. That is narrower and more truthful than a raw public escape hatch.

- question: are raw RPC error builders still a leak
- evidence-based answer: they remain open on input because they mirror raw JSON-RPC payload assembly, but the read side is typed through `Surrealdb_ErrorPayload.t`. This split is documented in `docs/TYPE_FIDELITY.md`.

## Failure Modes Targeted

- failure mode: typed decode APIs manufacture precision the runtime never proved
- how the current design prevents or exposes it: `decodeUnknown` stays open and `decodeWith` requires explicit caller classification
- test or probe covering it: `tests/value/SurrealdbValueSurface_test.res`

- failure mode: foreign error details collapse into fake Surreal values
- how the current design prevents or exposes it: `Surrealdb_ErrorPayload.t` preserves open payload structure and `Surrealdb_ServerError.detailData` returns `dict<Surrealdb_ErrorPayload.t>`
- test or probe covering it: `tests/errors/SurrealdbErrorPayloadSurface_test.res`, `tests/errors/SurrealdbErrorSupport_test.res`

- failure mode: record-id and range payloads recover through unchecked casts
- how the current design prevents or exposes it: public payload views go through `idValue` and `Surrealdb_BoundValue.t`
- test or probe covering it: `tests/value/SurrealdbValueSurface_test.res`, `tests/value/SurrealdbBindingValue_test.res`

## Evidence

### Build

- command: `NOT RUN`
- result: this retrofit only reorganized documentation and audit artifacts

### Tests

- command: `NOT RUN`
- result: current targeted test inventory is recorded in `docs/SOUNDNESS_MATRIX.md`; a future code-changing audit must refresh the runtime evidence directly

### Emitted JS Inspection

- file or command: `NOT RUN`
- result: no new interop site was introduced by this documentation retrofit

### Soundness Matrix Update

- affected row:
  - `Value / runtime class classification`
  - `Codec / decode boundary`
  - `Errors / foreign payload classification`
- update made: linked those rows to this bootstrap audit

## Residual Risk

- remaining open boundary: codec visitors, mixed foreign payloads, and raw RPC builder inputs still cross through `unknown`
- why it remains open: the runtime values are genuinely foreign at those seams and cannot be closed without lying
- where it is documented: `docs/TYPE_FIDELITY.md`, `docs/TYPE_SOUNDNESS_AUDIT.md`, `docs/SOUNDNESS_MATRIX.md`

## Verdict

- status:
  - acceptable with documented fidelity gap
- reviewer: Codex
- date: 2026-04-22
