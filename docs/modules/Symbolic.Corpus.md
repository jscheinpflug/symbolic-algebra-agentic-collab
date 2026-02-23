# Symbolic.Corpus

## Purpose

Define corpus case contracts for autonomous symbolic regression sets.

## Public Interface

- `CorpusCase`
- `Corpus`
- `CorpusExpectation`
- `evaluateCorpusCase`

## Invariants

- Corpus contracts are data-only in `TYPES` phase.
- Corpus expectation evaluation stays typed and returns project-owned failures.

## Feature Progress

- [x] Module scaffold created
- [x] Corpus type placeholders added
- [x] Corpus expectation contracts added
- [ ] Corpus execution and expectation checks

## Test Status

- `TESTS` phase: structured hspec coverage added under `test/Unit` and `test/Integration`.
- `TESTS` phase: corpus expectation and evaluation determinism coverage added in
  `test/Unit/SymbolicAlgebraAgenticCollab/Symbolic/CorpusTest.hs` and
  `test/Integration/Symbolic/PipelineIntegrationTest.hs`.

## Known Gaps / Next Steps

- Implement corpus expectation evaluation behavior in `IMPL` phase.

## Change Log

- 2026-02-23: Initial `TYPES` scaffold.
- 2026-02-23: Expanded `TESTS`-phase coverage with mirrored unit tests and integration suites.
- 2026-02-23: Added TYPES-phase corpus expectation contracts for IO pipeline planning.
- 2026-02-23: Added `TESTS`-phase corpus expectation and deterministic evaluation coverage.
