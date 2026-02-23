# Symbolic.Strategy

## Purpose

Define strategy contracts for controlling e-graph saturation policy and extraction behavior.

## Public Interface

- `Strategy`

## Invariants

- Strategy declarations are separate from parser logic.
- Strategy evaluation is deterministic by default.

## Feature Progress

- [x] Module scaffold created
- [x] Strategy type placeholders added
- [ ] Strategy-to-saturation interpreter behavior

## Test Status

- `TESTS` phase: structured hspec coverage added under `test/Unit` and `test/Integration`.

## Known Gaps / Next Steps

- Implement deterministic strategy interpretation over `hegg` saturation configuration in `IMPL` phase.

## Change Log

- 2026-02-23: Initial `TYPES` scaffold.
- 2026-02-23: Expanded `TESTS`-phase coverage with mirrored unit tests and integration suites.
- 2026-02-23: Updated strategy roadmap for e-graph policy control.
