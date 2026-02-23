# Symbolic.Engine.Search

## Purpose

Define search/saturation contracts and stats for deterministic e-graph execution.

## Public Interface

- `SearchMode`
- `SearchConfig`
- `SearchStats`

## Invariants

- Search contracts remain independent from parser and corpus layers.
- Search APIs map to bounded equality saturation and deterministic extraction.

## Feature Progress

- [x] Module scaffold created
- [x] Search contract placeholders added
- [ ] Bounded saturation and extraction behavior

## Test Status

- `TESTS` phase: structured hspec coverage added under `test/Unit` and `test/Integration`.

## Known Gaps / Next Steps

- Implement deterministic saturation orchestration on `hegg` with typed limit failures in `IMPL` phase.

## Change Log

- 2026-02-23: Initial `TYPES` scaffold.
- 2026-02-23: Expanded `TESTS`-phase coverage with mirrored unit tests and integration suites.
- 2026-02-23: Updated roadmap to e-graph saturation/extraction execution model.
