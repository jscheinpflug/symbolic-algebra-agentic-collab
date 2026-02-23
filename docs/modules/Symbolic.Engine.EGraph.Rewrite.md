# Symbolic.Engine.EGraph.Rewrite

## Purpose

Define typed contracts for compiling project `Rule` values into backend rewrite programs.

## Public Interface

- `compileRewriteProgram`
- `RewriteCompileError`
- `RewriteProgram`

## Invariants

- Rewrite compilation contracts use project-owned types and do not expose raw backend internals.
- Compilation rejects unsupported sequence-variable patterns and guarded rules.

## Feature Progress

- [x] Module scaffold created
- [x] Rewrite contract placeholders added
- [x] Deterministic rewrite validation implementation
- [x] Contract-level `TESTS` coverage added
- [ ] Direct backend rewrite lowering

## Test Status

- `TESTS` phase: unit coverage added in
  `test/Unit/SymbolicAlgebraAgenticCollab/Symbolic/Engine/EGraph/RewriteTest.hs`.

## Known Gaps / Next Steps

- Replace validation-only compilation with direct `hegg` rewrite lowering in a later implementation slice.

## Change Log

- 2026-02-23: Initial `TYPES` scaffold for rewrite compilation contracts.
- 2026-02-23: Added `TESTS`-phase unit and property coverage for rewrite contract determinism.
- 2026-02-23: Implemented deterministic rewrite program validation with typed compile failures.
