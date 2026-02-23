# Symbolic.Engine.EGraph.Translate

## Purpose

Define typed translation contracts between `Term` and opaque e-graph snapshots.

## Public Interface

- `EGraphBuildError`
- `termToEGraph`
- `eGraphToTerm`

## Invariants

- Translation APIs expose project-owned errors and do not leak backend types.
- Placeholder implementations in `TYPES` phase are non-final and intentionally conservative.

## Feature Progress

- [x] Module scaffold created
- [x] Translation contract placeholders added
- [ ] Deterministic translation behavior

## Test Status

- `TESTS` phase: pending for roundtrip subset and unsupported-shape errors.

## Known Gaps / Next Steps

- Add failing-first tests for translation contracts in `symbolic-egraph-foundation/TESTS`.
- Implement deterministic backend translation in `IMPL` phase.

## Change Log

- 2026-02-23: Initial `TYPES` scaffold for translation contracts.
