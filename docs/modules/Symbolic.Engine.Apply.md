# Symbolic.Engine.Apply

## Purpose

Define typed contracts for rule compilation/application wrappers on the `hegg` e-graph backend.

## Public Interface

- `ApplyConfig`
- `ApplyError`

## Invariants

- Apply APIs expose project-owned types and do not leak raw `hegg` internals.
- Apply contracts stay separate from saturation orchestration.

## Feature Progress

- [x] Module scaffold created
- [x] Apply contract placeholders added
- [ ] E-graph rewrite compilation implementation

## Test Status

- `TESTS` phase: structured hspec coverage added under `test/Unit` and `test/Integration`.

## Known Gaps / Next Steps

- Implement rule-to-rewrite compilation and typed apply failures over `hegg` in `IMPL` phase.

## Change Log

- 2026-02-23: Initial `TYPES` scaffold.
- 2026-02-23: Expanded `TESTS`-phase coverage with mirrored unit tests and integration suites.
- 2026-02-23: Updated roadmap to e-graph backend (`hegg`) wrapper model.
