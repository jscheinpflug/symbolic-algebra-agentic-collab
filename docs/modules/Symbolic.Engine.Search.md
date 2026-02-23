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
- [x] Strategy wrapper implementation wired
- [ ] Full strategy-to-backend planning behavior

## Test Status

- `TESTS` phase: structured hspec coverage added under `test/Unit` and `test/Integration`.
- `TESTS` phase: integration coverage added for deterministic repeated
  e-graph wrapper calls in `test/Integration/Symbolic/ContractsIntegrationTest.hs`.
- `TESTS` phase: strategy wrapper coverage added for deterministic repeated
  `runStrategy` calls in unit and integration suites.

## Known Gaps / Next Steps

- Replace rule-presence gating with strategy-directed planning semantics.
- Add trace-step population for successful strategy runs.
- Extend strategy execution to cover non-placeholder saturation/extraction backends.

## Change Log

- 2026-02-23: Initial `TYPES` scaffold.
- 2026-02-23: Expanded `TESTS`-phase coverage with mirrored unit tests and integration suites.
- 2026-02-23: Updated roadmap to e-graph saturation/extraction execution model.
- 2026-02-23: Added e-graph foundation wrapper contracts for snapshot build/recover flow.
- 2026-02-23: Added integration test coverage for deterministic wrapper behavior.
- 2026-02-23: Completed IMPL-phase wrapper wiring for build/recover contracts.
- 2026-02-23: Documented `runStrategy` contract to prepare deterministic strategy planning.
- 2026-02-23: Added `TESTS`-phase deterministic coverage for `runStrategy` wrapper contracts.
- 2026-02-23: Implemented deterministic `runStrategy` wrapper across saturation and extraction modules.
