# Symbolic.Engine.EGraph.Rewrite

## Purpose

Define typed contracts for compiling project `Rule` values into backend rewrite programs.

## Public Interface

- `RewriteCompileError`
- `RewriteProgram`

## Invariants

- Rewrite compilation contracts use project-owned types and do not expose raw backend internals.
- `TYPES` phase only defines shape and typed failures, not rewrite compilation behavior.

## Feature Progress

- [x] Module scaffold created
- [x] Rewrite contract placeholders added
- [x] Contract-level `TESTS` coverage added
- [ ] Rewrite compilation implementation

## Test Status

- `TESTS` phase: unit coverage added in
  `test/Unit/SymbolicAlgebraAgenticCollab/Symbolic/Engine/EGraph/RewriteTest.hs`.

## Known Gaps / Next Steps

- Implement rewrite compilation in `IMPL` phase.

## Change Log

- 2026-02-23: Initial `TYPES` scaffold for rewrite compilation contracts.
- 2026-02-23: Added `TESTS`-phase unit and property coverage for rewrite contract determinism.
