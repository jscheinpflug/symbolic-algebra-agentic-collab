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
- [x] Corpus execution entry wiring implemented
- [ ] Corpus expectation semantics enforcement

## Test Status

- `TESTS` phase: structured hspec coverage added under `test/Unit` and `test/Integration`.
- `TESTS` phase: corpus expectation and evaluation determinism coverage added in
  `test/Unit/SymbolicAlgebraAgenticCollab/Symbolic/CorpusTest.hs` and
  `test/Integration/Symbolic/PipelineIntegrationTest.hs`.

## Known Gaps / Next Steps

- Implement `caseExpectation` semantic checks over successful traces.

## Change Log

- 2026-02-23: Initial `TYPES` scaffold.
- 2026-02-23: Expanded `TESTS`-phase coverage with mirrored unit tests and integration suites.
- 2026-02-23: Added TYPES-phase corpus expectation contracts for IO pipeline planning.
- 2026-02-23: Added `TESTS`-phase corpus expectation and deterministic evaluation coverage.
- 2026-02-23: Wired `evaluateCorpusCase` to execute the shared pipeline entrypoint.
