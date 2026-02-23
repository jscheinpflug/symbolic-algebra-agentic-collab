# Symbolic.Engine.EGraph.Saturate

## Purpose

Define typed contracts for bounded equality saturation over e-graph snapshots.

## Public Interface

- `SaturationConfig`
- `SaturationError`
- `saturate`

## Invariants

- Saturation APIs expose typed project errors and do not leak raw backend e-graph types.
- `TYPES` phase saturation behavior is intentionally placeholder-only.

## Feature Progress

- [x] Module scaffold created
- [x] Saturation contract placeholders added
- [ ] Bounded saturation implementation

## Test Status

- `TESTS` phase pending: limit-failure and determinism tests will be added in `symbolic-egraph-saturation/TESTS`.

## Known Gaps / Next Steps

- Add failing-first tests for iteration/e-node/e-class limits and deterministic repeated runs in `TESTS`.
- Implement bounded saturation and typed limit exits in `IMPL` phase.

## Change Log

- 2026-02-23: Initial `TYPES` scaffold for saturation contracts.
