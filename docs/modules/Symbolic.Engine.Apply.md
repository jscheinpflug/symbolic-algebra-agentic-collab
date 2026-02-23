# Symbolic.Engine.Apply

## Purpose

Define typed contracts for rule compilation/application and saturation wrappers on the `hegg` e-graph backend.

## Public Interface

- `ApplyConfig`
- `ApplyError`
- `SaturationConfig`
- `SaturationError`
- `saturate`

## Invariants

- Apply APIs expose project-owned types and do not leak raw `hegg` internals.
- Apply contracts expose saturation orchestration through typed wrapper contracts.

## Feature Progress

- [x] Module scaffold created
- [x] Apply contract placeholders added
- [x] Saturation wrapper contracts added
- [x] Bounded saturation wrapper implementation wired
- [ ] Full backend rewrite + extraction implementation

## Test Status

- `TESTS` phase: structured hspec coverage added under `test/Unit` and `test/Integration`.
- `TESTS` phase: apply-layer saturation contract coverage added in
  `test/Unit/SymbolicAlgebraAgenticCollab/Symbolic/Engine/ApplyTest.hs`.

## Known Gaps / Next Steps

- Implement direct backend rewrite lowering and extraction-oriented apply flow in a later implementation slice.

## Change Log

- 2026-02-23: Initial `TYPES` scaffold.
- 2026-02-23: Expanded `TESTS`-phase coverage with mirrored unit tests and integration suites.
- 2026-02-23: Updated roadmap to e-graph backend (`hegg`) wrapper model.
- 2026-02-23: Added `TYPES`-phase saturation contracts via `SaturationConfig`, `SaturationError`, and `saturate`.
- 2026-02-23: Added `TESTS`-phase coverage for apply-level saturation contract re-exports.
- 2026-02-23: Wired `saturate` into bounded limit-checking implementation path.
