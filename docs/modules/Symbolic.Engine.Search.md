# Symbolic.Engine.Search

## Purpose

Define search/saturation contracts and stats for deterministic e-graph execution.

## Public Interface

- `SearchMode`
- `SearchConfig`
- `SearchStats`
- `buildSearchSnapshot`
- `recoverSearchTerm`
- `runStrategy`
- `EGraphBuildError`
- `EGraphSnapshot`
- `SaturationConfig`
- `SaturationError`
- `RewriteTrace`

## Invariants

- Search contracts remain independent from parser and corpus layers.
- Search APIs map to bounded equality saturation and deterministic extraction.
- `runStrategy` must enforce the `rule-cost`-then-`size` extraction objective.

## Feature Progress

- [x] Module scaffold created
- [x] Search contract placeholders added
- [x] E-graph translation wrapper contracts added
- [x] Foundation wrapper wiring implemented
- [x] Strategy planning contracts created (`runStrategy`)
- [ ] Bounded saturation and extraction behavior

## Test Status

- `TESTS` phase: structured hspec coverage added under `test/Unit` and `test/Integration`.
- `TESTS` phase: integration coverage added for deterministic repeated
  e-graph wrapper calls in `test/Integration/Symbolic/ContractsIntegrationTest.hs`.
- `TESTS` phase: strategy planning contracts will mirror the extraction / saturation path.

## Known Gaps / Next Steps

- Implement deterministic saturation orchestration on `hegg` with typed limit failures in `IMPL` phase.
- Add `runStrategy` wiring to orchestrate `SaturationConfig` plus extraction heuristics.
- Replace TYPES-phase `runStrategy` typed placeholder with full strategy execution flow.

## Change Log

- 2026-02-23: Initial `TYPES` scaffold.
- 2026-02-23: Expanded `TESTS`-phase coverage with mirrored unit tests and integration suites.
- 2026-02-23: Updated roadmap to e-graph saturation/extraction execution model.
- 2026-02-23: Added e-graph foundation wrapper contracts for snapshot build/recover flow.
- 2026-02-23: Added integration test coverage for deterministic wrapper behavior.
- 2026-02-23: Completed IMPL-phase wrapper wiring for build/recover contracts.
- 2026-02-23: Documented `runStrategy` contract to prepare deterministic strategy planning.
