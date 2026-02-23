# Symbolic.Engine.EGraph.Saturate

## Purpose

Define typed contracts for bounded equality saturation over e-graph snapshots.

## Public Interface

- `SaturationConfig`
- `SaturationError`
- `saturate`

## Invariants

- Saturation APIs expose typed project errors and do not leak raw backend e-graph types.
- Saturation enforces explicit iteration, e-node, and e-class limit checks before snapshot emission.

## Feature Progress

- [x] Module scaffold created
- [x] Saturation contract placeholders added
- [x] Contract-level `TESTS` coverage added
- [x] Bounded saturation wrapper implementation

## Test Status

- `TESTS` phase: unit coverage added in
  `test/Unit/SymbolicAlgebraAgenticCollab/Symbolic/Engine/EGraph/SaturateTest.hs`.
- `TESTS` phase: integration determinism coverage added in
  `test/Integration/Symbolic/ContractsIntegrationTest.hs`.

## Known Gaps / Next Steps

- Replace current bounded wrapper checks with full equality-saturation execution over compiled rewrites.

## Change Log

- 2026-02-23: Initial `TYPES` scaffold for saturation contracts.
- 2026-02-23: Added `TESTS`-phase unit/property/integration coverage for saturation contract determinism.
- 2026-02-23: Implemented deterministic bounded saturation checks with typed limit failures.
