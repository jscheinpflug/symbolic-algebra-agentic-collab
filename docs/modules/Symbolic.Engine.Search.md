# Symbolic.Engine.Search

## Purpose

Define search mode/config/stats contracts for rewrite exploration.

## Public Interface

- `SearchMode`
- `SearchConfig`
- `SearchStats`

## Invariants

- Search contracts remain independent from parser and corpus layers.

## Feature Progress

- [x] Module scaffold created
- [x] Search contract placeholders added
- [ ] Search execution behavior

## Test Status

- `TYPES` phase only: tests intentionally deferred.

## Known Gaps / Next Steps

- Add bounded-search tests in `TESTS` phase.

## Change Log

- 2026-02-23: Initial `TYPES` scaffold.
