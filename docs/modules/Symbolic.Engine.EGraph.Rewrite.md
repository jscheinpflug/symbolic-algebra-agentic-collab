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
- [ ] Rewrite compilation implementation

## Test Status

- `TESTS` phase pending: unit and integration coverage will be added in `symbolic-egraph-saturation/TESTS`.

## Known Gaps / Next Steps

- Add failing-first tests for rewrite compilation limits and deterministic behavior in `TESTS`.
- Implement rewrite compilation in `IMPL` phase.

## Change Log

- 2026-02-23: Initial `TYPES` scaffold for rewrite compilation contracts.
