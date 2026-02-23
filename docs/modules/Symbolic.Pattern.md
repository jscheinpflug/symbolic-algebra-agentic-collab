# Symbolic.Pattern

## Purpose

Define pattern AST nodes and substitution containers for rule matching.

## Public Interface

- `Name`
- `Pattern`
- `Subst`

## Invariants

- Pattern representation is independent of strategy/search layers.

## Feature Progress

- [x] Module scaffold created
- [x] Pattern type placeholders added
- [ ] Matching/instantiation behavior

## Test Status

- `TYPES` phase only: tests intentionally deferred.

## Known Gaps / Next Steps

- Add matcher behavior tests in `TESTS` phase.

## Change Log

- 2026-02-23: Initial `TYPES` scaffold.
