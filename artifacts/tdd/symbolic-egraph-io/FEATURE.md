## Problem

The symbolic system has strategy-layer contracts, but no typed IO/pipeline contracts that bind execution entrypoints, corpus expectations, and trace outcomes.

## Goal

Introduce TYPES-phase contracts for pipeline execution and corpus expectation evaluation so later phases can add deterministic tests and implementation without API drift.

## Non-Goals

- Implementing parser, pretty, corpus, or trace runtime behavior.
- Adding tests in this phase.
- Exposing backend internals from IO-facing modules.

## Public API Impact

Adds typed pipeline and corpus expectation signatures:

- `executeProgram`
- `CorpusExpectation`
- `evaluateCorpusCase`

## Risks

- Misplaced ownership across parser/corpus/trace modules could make later implementation inconsistent.
- Placeholder contracts that are too weak could leave TESTS-phase objective expectations ambiguous.

## Acceptance Criteria

- IO-layer contract signatures compile and remain backend-opaque.
- Module docs for parser, pretty, corpus, and trace are updated in the same PR.
- TYPES artifact validates with matching `module_docs` paths.
- No non-contract behavioral implementation is introduced in this phase.
