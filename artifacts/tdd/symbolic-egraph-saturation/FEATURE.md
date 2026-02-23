## Problem

The symbolic package has e-graph snapshot translation wrappers but no typed saturation contracts for bounded equality-saturation execution.

## Goal

Introduce `TYPES`-phase saturation contracts so later phases can add failing tests and deterministic implementation without API ambiguity.

## Non-Goals

- Implementing rewrite compilation or saturation behavior.
- Adding test files in this phase.
- Adding extraction or strategy orchestration in this phase.

## Public API Impact

Adds new public saturation contract types and function signatures for bounded e-graph saturation wrappers.

## Risks

- Overly weak placeholder contracts could make limit semantics unclear in later phases.
- Exposing backend details too early could couple package APIs to `hegg` internals.

## Acceptance Criteria

- Saturation modules and typed contracts compile.
- `Apply` re-exports saturation wrapper contracts.
- `TYPES` phase artifact validates with matching module docs updates.
- No saturation behavior implementation is introduced in this phase.
