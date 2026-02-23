## Problem

The symbolic package has tree-level type scaffolds but no e-graph foundation contracts for translating between `Term` values and internal `hegg` snapshots.

## Goal

Introduce the `TYPES`-phase contracts for the e-graph foundation so later phases can add tests and implementation without API ambiguity.

## Non-Goals

- Implementing real `hegg` translation behavior.
- Adding test files in this phase.
- Introducing saturation or extraction logic in this phase.

## Public API Impact

Adds new public type-level contracts for e-graph snapshot translation and search-layer wrapper functions.

## Risks

- Premature exposure of backend internals could couple public APIs to `hegg` details.
- Weak placeholder contracts could make TESTS phase ambiguous.

## Acceptance Criteria

- New e-graph foundation modules exist and compile.
- Search module exposes wrapper contracts for build/recover operations.
- `TYPES` phase artifact validates and policy checks pass.
- No real runtime behavior is introduced in this phase.
