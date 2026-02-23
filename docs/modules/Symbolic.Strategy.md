# Symbolic.Strategy

## Purpose

Define the `Strategy` type and related invariants that feed into
`Symbolic.Engine.Search.runStrategy`, which will be responsible for deterministic
saturation/extraction planning.

## Public Interface

- `Strategy`

## Invariants

- Strategy declarations are separate from parser logic.
- Strategy evaluation is deterministic by default.
- Strategy metadata should remain compatible with whatever `runStrategy` exposes to
  the saturation layer.

## Feature Progress

- [x] Module scaffold created
- [x] Strategy type placeholders added
- [ ] Strategy-to-saturation interpreter behavior

## Test Status

- `TESTS` phase: structured hspec coverage added under `test/Unit` and `test/Integration`.

## Known Gaps / Next Steps

- Align `Strategy` semantics with `Symbolic.Engine.Search.runStrategy` once strategy
  planning contracts are wired.
- Implement deterministic strategy interpretation over `hegg` saturation configuration in `IMPL` phase.
- Add objective-order tests (`rule-cost` then `size`) in `symbolic-egraph-strategy/TESTS`.

## Change Log

- 2026-02-23: Initial `TYPES` scaffold.
- 2026-02-23: Expanded `TESTS`-phase coverage with mirrored unit tests and integration suites.
- 2026-02-23: Updated strategy roadmap for e-graph policy control.
- 2026-02-23: Noted `runStrategy` tie-in for deterministic planning documentation.
