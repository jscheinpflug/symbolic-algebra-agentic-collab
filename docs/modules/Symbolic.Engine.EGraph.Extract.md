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
- TYPES-phase placeholders return typed saturation errors only.

## Feature Progress

- [x] Module scaffold created.
- [x] Cost-aware extraction contracts defined.
- [x] TYPES-phase typed placeholder behavior added.
- [ ] Deterministic extraction implementation wired.

## Test Status

- `TESTS` phase pending: strategy objective and tie-break coverage will be added
  in `symbolic-egraph-strategy/TESTS`.

## Known Gaps / Next Steps

- Add extraction heuristics that minimize `rule-cost` then `size`.
- Ensure extractor ties into `Strategy`-driven planning once the backend is
  available.

## Change Log

- 2026-02-23: Documented extraction contracts for the strategy roadmap.
- 2026-02-23: Added TYPES-phase typed placeholders for extraction contracts.
