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
- [x] Snapshot wrapper behavior implemented

## Test Status

- `TESTS` phase: unit coverage added for opaque snapshot contract in
  `test/Unit/SymbolicAlgebraAgenticCollab/Symbolic/Engine/EGraph/BuildTest.hs`.

## Known Gaps / Next Steps

- Wire saturated e-graph state (not just root-term snapshot wrapper) in later saturation slices.

## Change Log

- 2026-02-23: Initial `TYPES` scaffold for e-graph snapshot contract.
- 2026-02-23: Added `TESTS`-phase unit coverage for snapshot contract shape.
- 2026-02-23: Implemented IMPL-phase snapshot wrapper helpers for translation flow.
