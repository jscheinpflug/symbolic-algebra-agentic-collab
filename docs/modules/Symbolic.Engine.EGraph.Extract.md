# Symbolic.Engine.EGraph.Extract

## Purpose

Document extraction contracts for translating an equality graph snapshot back to
symbolic terms while exposing the deterministic cost metrics required by the
strategy layer.

## Public Interface

- `ExtractionCost`
- `extractBest`
- `extractBestWithCost`

## Invariants

- Extraction never surprises later strategy phases by depending on raw `hegg`
  types.
- The tuple returned by `extractBestWithCost` enforces that `costRule` is
  considered before `costSize` to mirror the deterministic tie-break plan.
- Extraction remains deterministic by ordering candidates on
  `(costRule, costSize, term)`.

## Feature Progress

- [x] Module scaffold created.
- [x] Cost-aware extraction contracts defined.
- [x] TYPES-phase typed placeholder behavior added.
- [x] Contract-level `TESTS` coverage added.
- [x] Deterministic extraction implementation wired.

## Test Status

- `TESTS` phase: unit coverage added in
  `test/Unit/SymbolicAlgebraAgenticCollab/Symbolic/Engine/EGraph/ExtractTest.hs`.
- `TESTS` phase: integration determinism coverage added in
  `test/Integration/Symbolic/ContractsIntegrationTest.hs`.

## Known Gaps / Next Steps

- Replace current structural candidate model with full backend-driven extraction.
- Extend `costRule` accounting to reflect realized rewrite usage.

## Change Log

- 2026-02-23: Documented extraction contracts for the strategy roadmap.
- 2026-02-23: Added TYPES-phase typed placeholders for extraction contracts.
- 2026-02-23: Added `TESTS`-phase unit/property/integration coverage for extraction contracts.
- 2026-02-23: Implemented deterministic candidate extraction with objective ordering.
