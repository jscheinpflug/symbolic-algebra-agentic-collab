# Symbolic.Engine.EGraph.Build

## Purpose

Define the opaque snapshot contract used to carry backend e-graph state.

## Public Interface

- `EGraphSnapshot` (opaque)

## Invariants

- Snapshot internals remain hidden from public API consumers.
- Backend implementation details are deferred to `IMPL` phase.

## Feature Progress

- [x] Module scaffold created
- [x] Snapshot contract placeholder added
- [ ] Backend snapshot construction behavior

## Test Status

- `TESTS` phase: pending for translation roundtrip and typed failure behavior.

## Known Gaps / Next Steps

- Add failing-first translation tests in `symbolic-egraph-foundation/TESTS`.
- Implement real backend snapshot wiring in `IMPL` phase.

## Change Log

- 2026-02-23: Initial `TYPES` scaffold for e-graph snapshot contract.
